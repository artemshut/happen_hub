class EventParticipationSerializer
  include JSONAPI::Serializer

  set_type :event_participation
  attributes :rsvp_status, :created_at, :updated_at

  belongs_to :user
end