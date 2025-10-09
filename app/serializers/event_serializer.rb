class EventSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :start_time, :end_time, :location, :slug, :latitude, :longitude, :visibility, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer
  belongs_to :event_category, serializer: EventCategorySerializer, if: proc { |event| event.event_category.present? }

  has_many :comments, serializer: CommentSerializer
  has_many :likes, serializer: LikeSerializer
  has_many :event_participations, serializer: EventParticipationSerializer
  has_many :users, through: :event_participations, serializer: UserSerializer

  attribute :cover_image_url do |event|
    if event.cover_image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        event.cover_image, only_path: false, host: "happenhub.co"
      )
    end
  end

  attribute :files do |event|
    event.files.map do |file|
      {
        filename: file.filename.to_s,
        content_type: file.content_type,
        byte_size: file.byte_size,
        url: Rails.application.routes.url_helpers.rails_blob_url(file, host: "happenhub.co"),
        signed_id: file.signed_id
      }
    end
  end
end
