# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :first_name, :last_name, :username, :tag

  attribute :avatar_url do |user|
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        user.avatar, 
        host: 'happenhub.co',
      )
    end
  end
end