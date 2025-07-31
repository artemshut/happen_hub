class Event < ApplicationRecord
  has_one_attached :cover_image

  belongs_to :group, optional: true
  belongs_to :event_category
  belongs_to :user, class_name: "User", foreign_key: "user_id", inverse_of: :owned_events
  has_many :event_participations, dependent: :destroy
  has_many :users, through: :event_participations
  has_many :event_suggestions, dependent: :destroy
  has_many :comments, dependent: :destroy

  before_validation :assign_default_category

  validates :title, :start_time, :end_time, presence: true

  # scope :upcoming, -> { where("start_time >= ?", Time.now) }
  scope :past, -> { where("start_time < ?", Time.now) }

  enum :visibility, { private: "private", friends: "friends" }, prefix: true

  has_rich_text :description

  def self.for_user(user)
    includes(:users)
      .where("events.user_id = ? OR event_participations.user_id = ?", user.id, user.id)
      .references(:event_participations)
  end

  def self.visible_for_friend(user)
    where(visibility: "friends")
      .joins("INNER JOIN friendships ON (friendships.user_id = events.user_id OR friendships.friend_id = events.user_id)")
      .where("friendships.user_id = :id OR friendships.friend_id = :id", id: user.id)
  end

  def self.upcoming(user)
    own_or_participating = left_joins(:event_participations).where("event_participations.user_id = ? OR events.user_id = ?", user.id, user.id).to_sql
    friends_visible = visible_for_friend(user).to_sql

    Event.from("(#{own_or_participating} UNION #{friends_visible}) AS events")
  end

  def add_friend_with_rsvp(user, rsvp_status = "pending")
    event_participations.create(user: user, rsvp_status: rsvp_status)
  end

  def owned_by?(current_user)
    user == current_user
  end

  private

  def assign_default_category
    self.event_category ||= EventCategory.find_by(name: "Other") || EventCategory.create(name: "Other", emoji: "📅", description: "General events")
  end
end
