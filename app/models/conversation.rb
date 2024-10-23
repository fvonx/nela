class Conversation < ApplicationRecord

  include Orderable
  include ProtocolReferenceable

  belongs_to :user
  has_many   :messages, dependent: :destroy
  has_one    :latest_message, -> { order(created_at: :desc) }, class_name: 'Message'

  before_validation :set_title, on: :create, unless: -> { title.present? }

  scope :unseen, -> { where('seen_at IS NULL OR updated_at > seen_at') }

  validates :title, presence: true
  validates :user,  presence: true

  accepts_nested_attributes_for :messages, allow_destroy: false, limit: 1

  def seen!
    update_column(:seen_at, Time.current)
  end

  def up_to_date?
    seen_at.present? && seen_at > updated_at
  end

  private

  def set_title
    self.title = messages.first&.title
  end

end