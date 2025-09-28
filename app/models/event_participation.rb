class EventParticipation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum :rsvp_status, { accepted: "accepted", declined: "declined", maybe: "maybe", pending: "pending" }, prefix: true

  scope :accepted, -> { where(rsvp_status: :accepted) }
  scope :declined, -> { where(rsvp_status: :declined) }
  scope :maybe, -> { where(rsvp_status: :maybe) }
  scope :pending, -> { where(rsvp_status: :pending) }

  validates :rsvp_status, presence: true

  after_create :notify_invitee

  def notify_invitee
    return if rsvp_status_declined? || rsvp_status_pending?

    # Notify the user about the event participation
    UserMailer.send_event_participation_notification(user, event).deliver_now
  end
end
