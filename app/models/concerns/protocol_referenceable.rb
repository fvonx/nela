module ProtocolReferenceable

  extend ActiveSupport::Concern

  included do
    before_validation :generate_protocol_ref, on: :create, unless: :protocol_ref?

    validates :protocol_ref, presence: true
  end

  private

  def generate_protocol_ref
    self.protocol_ref ||= SecureRandom.uuid
  end

end
