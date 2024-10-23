class Message < ApplicationRecord

  include Orderable
  include ProtocolReferenceable

  attr_accessor :receivers_input

  before_validation :set_receivers,            if: -> { receivers_input.present? }
  before_validation :set_sender,               if: :sending?, on: :create
  after_create      :enqueue_send_message_job, if: :sending?

  belongs_to :conversation,  touch: true
  has_many   :nela_messages, class_name: "Nela::Message"

  enum :direction, %i(sending receiving), default: :sending

  validates :title,        presence: true
  validates :body,         presence: true
  validates :direction,    presence: true
  validates :sender,       presence: true, address: true
  validates :receivers,    presence: true, address_array: true
  validates :conversation, presence: true

  def self.from_nela_message(nela_message)
    new(
      sender:       nela_message.sender,
      receivers:    nela_message.all_receivers,
      title:        nela_message.title,
      body:         nela_message.body,
      protocol_ref: nela_message.message_ref,
      direction:    :receiving
    )
  end

  def handshaked?
    self.handshaked_at.present?
  end

  def handshake!
    self.update!(handshaked_at: Time.current)
  end

  private

  def set_receivers
    self.receivers = receivers_input.split(',').map(&:strip)
  end

  def set_sender
    self.sender = conversation.user.address
  end

  def enqueue_send_message_job
    SendMessageJob.perform_later(id)
  end

end