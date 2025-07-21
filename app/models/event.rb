class Event < ApplicationRecord
  has_one_attached :cover_image

  belongs_to :group, optional: true
  belongs_to :user
  has_many :rsvps, dependent: :destroy
  has_many :event_participations, dependent: :destroy
  has_many :users, through: :event_participations
  has_many :event_suggestions, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :title, :start_time, :end_time, presence: true

  after_create :send_create_email_notification

  scope :upcoming, -> { where('start_time >= ?', Time.now) }
  scope :past, -> { where('start_time < ?', Time.now) }

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

  def add_friend_with_rsvp(user, rsvp_status = 'pending')
    event_participations.create(user: user, rsvp_status: rsvp_status)
  end

  def send_create_email_notification
    EnveloopMailer.user_welcome_email(event.user).deliver_now
  end

  def owned_by?(current_user)
    user == current_user
  end
end