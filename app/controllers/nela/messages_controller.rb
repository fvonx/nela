module Nela

  class MessagesController < ApplicationController

    include SenderVerifiable

    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    before_action :ensure_signature_and_certificate, only: %i[create]

    def create
      verifier = SignatureVerifier.new(
        message_data:     message_params,
        signature_base64: @signature_base64,
        certificate_pem:  @certificate_pem,
        expected_domain:  sender_domain
      )

      if verifier.verify
        @message = Nela::Message.new(message_params.merge(direction: :receiving))

        if @message.save
          render json: { message: 'Message received', id: @message.id }, status: :created
        else
          render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: ['Invalid signature'] }, status: :unauthorized
      end
    end

    private

    def message_params
      params.require(:message).permit(
        :sender,
        :direct_receiver,
        :title,
        :body,
        :conversation_ref,
        :message_ref,
        :handshake_ref,
        all_receivers: []
      ).to_h
    end

    def sender_domain
      return nil unless message_params['sender']

      message_params['sender'].split('@').last
    end

  end

end