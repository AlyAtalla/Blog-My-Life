class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"

  validates :body, presence: true, length: { maximum: 2000 }

  scope :between, ->(a, b) { where(sender: a, recipient: b).or(where(sender: b, recipient: a)).order(:created_at) }
  scope :unread_for, ->(user) { where(recipient: user, read_at: nil) }
end
