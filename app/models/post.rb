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

  # Return up to `limit` users who most recently interacted with this post
  # (either by liking or commenting). Returns User records ordered by latest
  # interaction time (most recent first).
  def recent_interactors(limit = 4)
    # Collect pairs of [user, timestamp]
    pairs = []
    likes.includes(:user).each do |l|
      pairs << [ l.user, l.created_at ] if l.user
    end
    comments.includes(:user).each do |c|
      pairs << [ c.user, c.created_at ] if c.user
    end

    # Reduce to latest timestamp per user
    latest = {}
    pairs.each do |user, ts|
      next unless user
      uid = user.id
      latest[uid] = { user: user, ts: ts } unless latest[uid]
      latest[uid][:ts] = ts if ts && latest[uid][:ts] < ts
    end

    # Sort by timestamp desc and return the User objects limited
    latest.values.sort_by { |h| - (h[:ts].to_i) }.map { |h| h[:user] }.first(limit)
  end
end
