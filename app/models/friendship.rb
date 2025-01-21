class Friendship < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: "User"

  enum :status, { pending: "pending", accepted: "accepted", declined: "declined" }

  validates :user_id, uniqueness: { scope: :friend_id, message: "Friend request already sent" }
end
