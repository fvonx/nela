module Orderable

  extend ActiveSupport::Concern

  included do
    scope :most_recent_first, -> { order(updated_at: :desc) }
    scope :oldest_first,      -> { order(updated_at: :asc) }
  end

end
