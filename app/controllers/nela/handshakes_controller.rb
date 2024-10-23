module Nela

  class HandshakesController < ApplicationController

    include SenderVerifiable
  
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    before_action :set_message
    before_action :ensure_signature_and_certificate, only: %i[update]

    def update
      handshake_data = {
        sender:           @message.sender,
        direct_receiver:  @message.direct_receiver,
        conversation_ref: @message.conversation_ref,
        message_ref:      @message.message_ref,
        handshake_ref:    @message.handshake_ref
      }

      verifier = SignatureVerifier.new(
        message_data:     handshake_data,
        signature_base64: @signature_base64,
        certificate_pem:  @certificate_pem,
        expected_domain:  @message.direct_receiver_domain
      )

      if verifier.verify
        if @message
          render json: { message: 'Message handshake accepted', id: @message.message_ref }, status: :ok
        else
          render json: { errors: ['Message not found'] }, status: :not_found
        end
      else
        render json: { errors: ['Invalid signature'] }, status: :unauthorized
      end
    end

    private

    def set_message
      @message = Nela::Message.find_by(message_ref: params[:message_id], handshake_ref: params[:id])
    end
  
  end

end