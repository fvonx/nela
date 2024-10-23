class ReceiveMessageJob < ApplicationJob

  queue_as :default

  def perform(message_id)
    nela_message = Nela::Message.find(message_id)

    if (user = nela_message.receiving_user)
      message = nil

      ActiveRecord::Base.transaction do
        conversation       = user.conversations.find_or_initialize_by(protocol_ref: nela_message.conversation_ref)
        conversation.title = nela_message.title
        conversation.save!

        message              = Message.from_nela_message(nela_message)
        message.conversation = conversation
        message.save!
      end

      send_handshake_to_sender(nela_message, message) if message
    else
      Rails.logger.error "No receiving user found for Nela Message #{message_id}."
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to process Nela Message #{message_id}: #{e.message}"
  end

  private

  def send_handshake_to_sender(nela_message, message)
    domain = nela_message.sender_domain
    uri    = "https://#{domain}/nela/messages/#{nela_message.message_ref}/handshakes/#{nela_message.handshake_ref}"

    handshake_data = {
      sender:           nela_message.sender,
      direct_receiver:  nela_message.direct_receiver,
      conversation_ref: nela_message.conversation_ref,
      message_ref:      nela_message.message_ref,
      handshake_ref:    nela_message.handshake_ref
    }

    sender = SecureRequestSender.new("PUT", uri, handshake_data)
    result = sender.send_request

    if result[:success]
      Rails.logger.info "Handshake for message #{nela_message.message_ref} successfully sent."
      message.handshake!
    else
      Rails.logger.error "Failed to send handshake for message #{nela_message.message_ref} to #{domain}. #{result[:message]}"
    end
  rescue StandardError => e
    Rails.logger.error "Error sending handshake for message #{nela_message.message_ref} to #{domain}: #{e.message}."
  end

end