class Event < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :user
  has_many :rsvps, dependent: :destroy
  has_many :event_participations, dependent: :destroy
  has_many :users, through: :event_participations
  has_many :event_suggestions, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, :start_time, :end_time, presence: true

  scope :upcoming, -> { where('start_time >= ?', Time.now) }
  scope :past, -> { where('start_time < ?', Time.now) }

  enum :visibility, { private: "private", friends: "friends" }, prefix: true

  has_rich_text :description

  def self.for_user(user)
    includes(:users)
      .where("events.user_id = ? OR event_participations.user_id = ?", user.id, user.id)
      .references(:event_participations)
  end 

  def add_friend_with_rsvp(user, rsvp_status = 'pending')
    event_participations.create(user: user, rsvp_status: rsvp_status)
  end
end