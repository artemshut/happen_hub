# frozen_string_literal: true

class SubEventSerializer
  include JSONAPI::Serializer

  attributes :id, :event_id, :title, :start_time, :end_time, :location, :notes, :position, :created_at, :updated_at

  attribute :duration_minutes do |sub_event|
    next unless sub_event.start_time.present? && sub_event.end_time.present?

    ((sub_event.end_time - sub_event.start_time) / 60).to_i
  end
end
