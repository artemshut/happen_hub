# frozen_string_literal: true

class InviteeAvailabilityService
  STATUSES = {
    busy: "busy",
    free: "free",
    tentative: "tentative",
    unknown: "unknown"
  }.freeze

  CONFLICT_RSVP_STATUSES = %w[accepted maybe pending].freeze
  TENTATIVE_RSVP_STATUSES = %w[maybe pending].freeze

  def self.call(...)
    new(...).call
  end

  def initialize(event:, invitee:)
    @event = event
    @invitee = invitee
  end

  def call
    return unknown_result("Target event is missing time information.") unless valid_event_times?
    return unknown_result("Invitee has participations with incomplete time data.") if invitee_has_incomplete_participations?

    conflicts = overlapping_participations.includes(:event).map do |participation|
      serialize_conflict(participation)
    end

    { status: determine_status(conflicts), conflicts: conflicts }
  end

  private

  attr_reader :event, :invitee

  def determine_status(conflicts)
    return STATUSES[:busy] if conflicts.any? { |conflict| conflict[:rsvp_status] == "accepted" }
    return STATUSES[:tentative] if conflicts.any? { |conflict| TENTATIVE_RSVP_STATUSES.include?(conflict[:rsvp_status]) }

    STATUSES[:free]
  end

  def overlapping_participations
    EventParticipation
      .joins(:event)
      .where(user: invitee, rsvp_status: CONFLICT_RSVP_STATUSES)
      .where.not(events: { id: event.id })
      .where.not(events: { start_time: nil, end_time: nil })
      .where("events.start_time < ? AND events.end_time > ?", event.end_time, event.start_time)
  end

  def invitee_has_incomplete_participations?
    EventParticipation
      .joins(:event)
      .where(user: invitee, rsvp_status: CONFLICT_RSVP_STATUSES)
      .where("events.start_time IS NULL OR events.end_time IS NULL")
      .exists?
  end

  def valid_event_times?
    event.start_time.present? && event.end_time.present?
  end

  def serialize_conflict(participation)
    {
      event_id: participation.event_id,
      title: participation.event.title,
      start_time: participation.event.start_time,
      end_time: participation.event.end_time,
      rsvp_status: participation.rsvp_status
    }
  end

  def unknown_result(message)
    { status: STATUSES[:unknown], conflicts: [], note: message }
  end
end
