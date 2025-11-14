class User < ApplicationRecord
  has_secure_password
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 100 }
  VALID_EMAIL = /\A[^@\s]+@[^@\s]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL }
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?
end