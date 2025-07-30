class EventSuggestion < ApplicationRecord
  has_many :likes, as: :likeable, dependent: :destroy

  belongs_to :event
  belongs_to :user

  enum :status, { pending: "pending", approved: "approved", rejected: "rejected" }

  validates :event, :user, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :event_id, uniqueness: { scope: :user_id, message: "You have already suggested time for this event" }
  validate :event_not_in_past
  validate :suggested_end_time_after_start_time
  validate :suggested_start_time_before_event_end_time
  validate :user_not_participating

  private

  def event_not_in_past
    if event.start_time < Time.current
      errors.add(:event, "cannot be suggested for an event in the past")
    end
  end

  def user_not_participating
    if event.event_participations.exists?(user_id: user.id)
      errors.add(:user, "is already participating in this event")
    end
  end

  def suggested_end_time_after_start_time
    if suggested_end_time && suggested_start_time && suggested_end_time <= suggested_start_time
      errors.add(:suggested_end_time, "must be after the suggested start time")
    end
  end

  def suggested_start_time_before_event_end_time
    if suggested_start_time && event.end_time && suggested_start_time >= event.end_time
      errors.add(:suggested_start_time, "must be before the event's end time")
    end
  end
end
