# app/serializers/event_serializer.rb
class EventSerializer
  include JSONAPI::Serializer

  set_type :event
  attributes :title, :description, :start_time, :end_time, :location, :slug

  belongs_to :user, serializer: UserSerializer
  belongs_to :event_category, serializer: EventCategorySerializer
  has_many :comments, serializer: CommentSerializer
  # has_many :likes, serializer: LikeSerializer
  has_many :event_participations, serializer: EventParticipationSerializer
end