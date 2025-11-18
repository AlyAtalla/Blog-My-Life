class User < ApplicationRecord
  has_secure_password
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id', dependent: :destroy
  has_many :received_messages, class_name: 'Message', foreign_key: 'recipient_id', dependent: :destroy

  before_save { email.downcase! }
  validates :name, presence: true, length: { maximum: 100 }
  VALID_EMAIL = /\A[^@\s]+@[^@\s]+\z/
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL }
  validates :password, length: { minimum: 6 }, if: :password_digest_changed?
  
  def unread_messages_count
    received_messages.where(read_at: nil).count
  end
end