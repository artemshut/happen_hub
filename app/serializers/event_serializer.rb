class EventSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :start_time, :end_time, :location, :slug, :latitude, :longitude

  belongs_to :user, serializer: UserSerializer
  belongs_to :event_category, serializer: EventCategorySerializer, if: Proc.new { |event| event.event_category.present? }

  has_many :comments, serializer: CommentSerializer
  has_many :likes, serializer: LikeSerializer
  has_many :participants, serializer: UserSerializer do |event|
    event.users
  end
  has_many :event_participations, serializer: EventParticipationSerializer
end