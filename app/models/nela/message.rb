class Nela::Message < ApplicationRecord

  self.table_name = 'nela_messages'

  belongs_to :message, optional: true

  before_validation :generate_handshake_ref, unless: :handshake_ref?, on: :create
  after_create      :enqueue_receive_message_job, if: :receiving?

  enum :direction, %i(sending receiving), default: :sending

  validates :title,            presence: true
  validates :body,             presence: true
  validates :sender,           presence: true, address: true
  validates :direct_receiver,  presence: true, address: true
  validates :all_receivers,    presence: true, address_array: true
  validates :message_ref,      presence: true
  validates :conversation_ref, presence: true
  validates :handshake_ref,    presence: true
  validates :direction,        presence: true

  def self.from_message(message, receiver)
    conversation = message.conversation

    new(
      sender:           message.sender,
      direct_receiver:  receiver,
      all_receivers:    message.receivers,
      title:            message.title,
      body:             message.body,
      message_ref:      message.protocol_ref,
      conversation_ref: conversation.protocol_ref,
      message:          message,
      direction:        :sending
    )
  end

  def receiving_user
    handle = self.direct_receiver.split('@').first
    @receiving_user ||= User.find_by(handle: handle)
  end

  def sender_domain
    domain_for(self.sender)
  end

  def direct_receiver_domain
    domain_for(self.direct_receiver)
  end

  private

  def generate_handshake_ref
    self.handshake_ref ||= SecureRandom.uuid
  end

  def enqueue_receive_message_job
    ReceiveMessageJob.perform_later(id)
  end

  def domain_for(address)
    address.split('@').last
  end

end
