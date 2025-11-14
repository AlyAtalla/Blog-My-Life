class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true

  def likes_count
    likes.size
  end

  def liked_by?(user)
    return false unless user
    likes.any? { |l| l.user_id == user.id }
  end
end