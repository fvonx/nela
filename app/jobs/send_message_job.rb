class SendMessageJob < ApplicationJob

  queue_as :default

  def perform(message_id)
    message = Message.find(message_id)

    message.receivers.each do |receiver|
      nela_message = Nela::Message.from_message(message, receiver)

      if nela_message.save
        send_message_to_receiver(nela_message)
      else
        Rails.logger.info "Failed to save Nela::Message for #{receiver}."
      end
    end
  end

  private

  def send_message_to_receiver(message)
    domain = message.direct_receiver.split('@').last
    uri    = "https://#{domain}/nela/messages"

    message_data = {
      title:            message.title,
      body:             message.body,
      sender:           message.sender,
      direct_receiver:  message.direct_receiver,
      all_receivers:    message.all_receivers,
      conversation_ref: message.conversation_ref,
      message_ref:      message.message_ref,
      handshake_ref:    message.handshake_ref
    }

    sender = SecureRequestSender.new("POST", uri, message_data)
    result = sender.send_request

    if result[:success]
      Rails.logger.info "Message #{message.message_ref} successfully sent to #{message.direct_receiver}."
    else
      Rails.logger.error "Failed to send message #{message.message_ref} to #{message.direct_receiver}. #{result[:message]}"
    end
  end

end