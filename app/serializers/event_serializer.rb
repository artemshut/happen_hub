class EventSerializer
  include JSONAPI::Serializer

  attributes :id, :title, :description, :start_time, :end_time, :location, :slug, :latitude, :longitude, :visibility, :created_at, :updated_at

  belongs_to :user, serializer: UserSerializer
  belongs_to :event_category, serializer: EventCategorySerializer, if: proc { |event| event.event_category.present? }

  has_many :comments, serializer: CommentSerializer
  has_many :likes, serializer: LikeSerializer

  attribute :cover_image_url do |event, params|
    host = params[:host] || "happenhub.co"
    if event.cover_image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        event.cover_image, only_path: false, host: host
      )
    end
  end

  attribute :files do |event, params|
    host = params[:host] || "happenhub.co"
    event.files.map do |file|
      {
        filename: file.filename.to_s,
        content_type: file.content_type,
        byte_size: file.byte_size,
        url: Rails.application.routes.url_helpers.rails_blob_url(file, host: host),
        signed_id: file.signed_id
      }
    end
  end

  attribute :participant_count do |event|
    event.participant_count
  end

  attribute :participants do |event, params|
    viewer = params[:current_user]
    host = params[:host] || "happenhub.co"

    event.participant_scope_for(viewer).map do |participation|
      user = participation.user
      {
        id: user.id,
        first_name: user.first_name,
        last_name: user.last_name,
        username: user.username,
        status: participation.rsvp_status,
        is_owner: user.id == event.user_id,
        avatar_url: user.avatar.attached? ? Rails.application.routes.url_helpers.rails_blob_url(user.avatar, host: host, only_path: false) : nil
      }
    end
  end
end
