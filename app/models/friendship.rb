class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: "pending", accepted: "accepted", declined: "declined" }

  validates :user_id, uniqueness: { scope: :friend_id, message: "Friend request already sent" }

  after_create :notify_friend

  def self.between(user1, user2)
    where(user_id: user1.id, friend_id: user2.id)
      .or(where(user_id: user2.id, friend_id: user1.id))
      .first
  end

  private

  def notify_friend
    return if status != "pending"

    # Notify the friend about the new friendship request
    UserMailer.send_friend_request_notification(friend, user).deliver_now
  end
end
