class EventParticipation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum :rsvp_status, { accepted: "accepted" , declined: "declined", maybe: "maybe", pending: "pending" }, prefix: true

  scope :accepted, -> { where(rsvp_status: :accepted) }
  scope :declined, -> { where(rsvp_status: :declined) }
  scope :maybe, -> { where(rsvp_status: :maybe) }
  scope :pending, -> { where(rsvp_status: :pending) }

  validates :rsvp_status, presence: true
end