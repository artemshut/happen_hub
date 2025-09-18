class EventCategorySerializer
  include JSONAPI::Serializer

  set_type :event_category
  attributes :name, :emoji, :description
end
