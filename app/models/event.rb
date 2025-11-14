class Event < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_one_attached :cover_image
  has_many_attached :files
  attr_accessor :pending_files

  belongs_to :group, optional: true
  belongs_to :event_category
  belongs_to :user, class_name: "User", foreign_key: "user_id", inverse_of: :owned_events
  has_many :event_participations, dependent: :destroy
  has_many :users, through: :event_participations
  has_many :event_suggestions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy

  before_validation :assign_default_category
  before_validation :ensure_share_token
  after_commit :schedule_reminders!, on: %i[create update]

  validates :title, :start_time, :end_time, presence: true
  validate :validate_file_sizes
  validate :respect_plan_limits, on: :create

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

    filtered_scope = scope.where(rsvp_status: VISIBLE_PARTICIPATION_STATUSES)
    return filtered_scope.none unless viewer

    allowed_ids = viewer.friend_ids + [ viewer.id ]
    filtered_scope = filtered_scope.where(user_id: allowed_ids.uniq)

    if viewer.friends_with?(user)
      owner_scope = scope.where(user_id: user_id)
      filtered_scope = filtered_scope.or(owner_scope)
    end

    filtered_scope
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

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map(&:name)
  end

  def share_url(host: default_url_host, protocol: default_url_protocol)
    Rails.application.routes.url_helpers.share_event_url(share_token, host: host, protocol: protocol)
  end

  def increment_share_clicks!
    increment!(:share_clicks)
  end

  def increment_share_views!
    increment!(:share_views)
  end

  private

  def default_url_host
    Rails.application.config.action_mailer.default_url_options&.dig(:host) ||
      Rails.application.routes.default_url_options[:host] ||
      "localhost:3000"
  end

  def default_url_protocol
    Rails.application.config.action_mailer.default_url_options&.dig(:protocol) ||
      Rails.application.routes.default_url_options[:protocol] ||
      "https"
  end

  def ensure_share_token
    self.share_token ||= generate_share_token
  end

  def generate_share_token
    loop do
      token = SecureRandom.urlsafe_base64(12)
      break token unless Event.exists?(share_token: token)
    end
  end

  def assign_default_category
    self.event_category ||= EventCategory.find_by(name: "Other") || EventCategory.create(name: "Other", emoji: "📅", description: "General events")
  end

  def validate_file_sizes
    (files.to_a + Array(pending_files)).compact.each do |file|
      size = file_size_for_validation(file)
      next if size <= 10.megabytes

      errors.add(:files, "#{file_label_for_validation(file)} is too large. Each file must be under 10 MB.")
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

  def file_size_for_validation(file)
    if file.respond_to?(:byte_size)
      file.byte_size
    elsif file.respond_to?(:size)
      file.size.to_i
    else
      0
    end
  end

  def file_label_for_validation(file)
    if file.respond_to?(:filename)
      file.filename.to_s
    elsif file.respond_to?(:original_filename)
      file.original_filename.to_s
    else
      "Attachment"
    end
  end

  def respect_plan_limits
    return unless user
    return if user.can_create_event?

    errors.add(:base, "Your #{user.plan&.name} plan has reached its active event limit. Upgrade to create more gatherings.")
  end
end
