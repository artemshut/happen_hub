class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :target, polymorphic: true, optional: true

  validates :action, presence: true

  # Scopes for filtering activities
  scope :recent, -> { order(created_at: :desc).limit(10) }
  scope :for_user, ->(user) { where(user: user) }
  scope :for_friends, ->(user) { where(user_id: user.friends.ids) }

  enum :action, { created_event: 0, joined_event: 1, joined_group: 2, created_group: 3, updated_profile: 4, friend_request_sent: 5, friend_request_accepted: 6 }
end
