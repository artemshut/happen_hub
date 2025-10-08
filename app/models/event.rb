class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_one_attached :cover_image
  has_many_attached :files

  belongs_to :group, optional: true
  belongs_to :event_category
  belongs_to :user, class_name: "User", foreign_key: "user_id", inverse_of: :owned_events
  has_many :event_participations, dependent: :destroy
  has_many :users, through: :event_participations
  has_many :event_suggestions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  before_validation :assign_default_category
  after_commit :schedule_24h_reminder!, on: %i[create update]

  validates :title, :start_time, :end_time, presence: true
  validate :validate_file_sizes

  enum :visibility, { private: "private", friends: "friends" }, prefix: true

  has_rich_text :description

  def self.for_user(user)
    own_or_participating = left_joins(:event_participations)
                             .where("event_participations.user_id = ? OR events.user_id = ?", user.id, user.id)
                             .where("event_participations.rsvp_status IN (?)", ["accepted", "maybe"])
                             .to_sql
    friends_visible = visible_for_friend(user).to_sql

    Event.from("(#{own_or_participating} UNION #{friends_visible}) AS events").order("start_time DESC")
  end

  def past?
    end_time < Time.current
  end

  # Force regenerate slug if title changes
  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def self.visible_for_friend(user)
    where(visibility: "friends")
      .joins("INNER JOIN friendships ON (friendships.user_id = events.user_id OR friendships.friend_id = events.user_id)")
      .where("friendships.user_id = :id OR friendships.friend_id = :id", id: user.id)
  end

  def self.past(user)
    own_or_participating = left_joins(:event_participations)
                             .where("event_participations.user_id = ? OR events.user_id = ?", user.id, user.id)
                             .where("event_participations.rsvp_status IN (?)", ["accepted", "maybe"])
                             .to_sql
    friends_visible = visible_for_friend(user).to_sql

    Event.where("start_time < ?", Date.today).from("(#{own_or_participating} UNION #{friends_visible}) AS events").order("start_time DESC")
  end

  def self.upcoming(user)
    ### Events that the user owns or is participating in with status accepted or maybe
    Event.for_user(user).where("start_time >= ?", Date.today)
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

  def validate_file_sizes
    files.each do |file|
      if file.byte_size > 10.megabytes
        errors.add(:files, "#{file.filename} is too large. Each file must be under 10 MB.")
      end
    end
  end

  def schedule_24h_reminder!
    return if start_time.blank?

    run_at = start_time - 24.hours
    # If start_time is less than 24h away, schedule soon
    run_at = Time.current + 1.minute if run_at <= Time.current

    # Cancel any existing scheduled jobs for this event
    SolidQueue::ScheduledExecution
      .where(job_class: "EventReminderJob", arguments: [id])
      .delete_all

    # Schedule a new reminder
    EventReminderJob.set(wait_until: run_at).perform_later(id)

    Rails.logger.info("🗓 Scheduled 24h reminder for event ##{id} at #{run_at}")
  end
end
