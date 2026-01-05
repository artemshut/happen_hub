class EventChecklistSerializer
  include JSONAPI::Serializer

  attributes :title, :position, :event_id, :created_at, :updated_at

  has_many :items, serializer: EventChecklistItemSerializer do |checklist|
    checklist.items
  end
end
