class EventCategorySerializer
  include JSONAPI::Serializer

  attributes :id, :name, :emoji, :description
end