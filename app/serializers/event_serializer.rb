class EventSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :start_time, :end_time, :slug

  belongs_to :user, serializer: UserSerializer
end