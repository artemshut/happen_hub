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
  after_commit :schedule_reminders!, on: %i[create update]

  validates :title, :start_time, :end_time, presence: true
  validate :validate_file_sizes

  enum :visibility, { private: "private", friends: "friends", public: "public" }, prefix: true

  has_rich_text :description

  VISIBLE_PARTICIPATION_STATUSES = %w[accepted maybe].freeze

  scope :ordered_by_start, -> { order(start_time: :asc) }
  scope :past, -> { where(arel_table[:start_time].lt(Time.current)) }
  scope :upcoming, -> { where(arel_table[:start_time].gteq(Time.current)) }

  def participant_count
    event_participations.where(rsvp_status: VISIBLE_PARTICIPATION_STATUSES).count
  end

  def participant_scope_for(viewer)
    scope = event_participations.includes(:user)

    return scope unless visibility_public?

    scope = scope.where(rsvp_status: VISIBLE_PARTICIPATION_STATUSES)
    return scope.none unless viewer

    allowed_ids = viewer.friend_ids + [ viewer.id ]
    allowed_ids << user_id if viewer.friends_with?(user)

    scope.where(user_id: allowed_ids.uniq)
  end

  def participants_grouped_for(viewer)
    participant_scope_for(viewer).group_by { |participation| participation.rsvp_status.to_sym }
  end

  def friend_participants_for(viewer)
    participant_scope_for(viewer)
  end

  def past?
    end_time < Time.current
  end

  # Force regenerate slug if title changes
  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def self.visible_to(user)
    scope = where(visibility: :public)

    return scope unless user

    event_table = arel_table

    participation_subquery = EventParticipation
                              .where(user_id: user.id, rsvp_status: VISIBLE_PARTICIPATION_STATUSES)
                              .select(:event_id)
                              .arel

    condition = event_table[:user_id].eq(user.id)
    condition = condition.or(event_table[:id].in(participation_subquery))

    friend_ids = user.friend_ids
    if friend_ids.any?
      friends_condition =
        event_table[:user_id].in(friend_ids)
                   .and(event_table[:visibility].eq(Event.visibilities[:friends]))
      condition = condition.or(friends_condition)
    end

    scope.or(where(condition))
  end

  def self.past_for(user)
    visible_to(user).past.order(start_time: :desc)
  end

  def self.upcoming_for(user)
    visible_to(user).upcoming.ordered_by_start
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

  def schedule_reminders!
    return if start_time.blank?

    schedule_at_offset!(1440) # 24 hours
    schedule_at_offset!(60)   # 1 hour
  end

  def schedule_at_offset!(minutes_before)
    run_at = start_time - minutes_before.minutes
    run_at = Time.current + 1.minute if run_at <= Time.current

    if Rails.env.production?
      remove_duplicate_reminders!(minutes_before)
      EventReminderJob.set(wait_until: run_at).perform_later(id, minutes_before)

      Rails.logger.info "🗓 Scheduled reminder (#{minutes_before}min) for event ##{id} at #{run_at}"
    end
  end

  def remove_duplicate_reminders!(minutes_before)
    SolidQueue::ScheduledExecution
      .joins(:job)
      .where(solid_queue_jobs: { class_name: "EventReminderJob" })
      .find_each do |execution|
        next unless reminder_arguments?(execution.job.arguments, minutes_before)

        execution.destroy
      end
  rescue StandardError => e
    Rails.logger.warn "⚠️ Failed to clean up existing reminders for event ##{id}: #{e.message}"
  end

  def reminder_arguments?(raw_arguments, minutes_before)
    decoded = decode_arguments(raw_arguments)
    decoded == [ id, minutes_before ]
  end

  def decode_arguments(raw_arguments)
    JSON.parse(raw_arguments)
  rescue JSON::ParserError, TypeError
    YAML.safe_load(raw_arguments, permitted_classes: [ Symbol, Time, Date, ActiveSupport::TimeWithZone ])
  end
end
