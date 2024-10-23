class User < ApplicationRecord

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_many :conversations, dependent: :destroy

  validates :email,  presence: true, uniqueness: { case_sensitive: false }, address: true
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers, and underscores" }

  def address
    "#{self.handle}@#{Rails.configuration.nela.domain}"
  end

end
