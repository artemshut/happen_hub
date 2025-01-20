class EventParticipation < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum :rsvp_status, { accepted: "accepted" , declined: "declined", maybe: "maybe", pending: "pending" }, prefix: true
end