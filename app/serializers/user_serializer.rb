class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :first_name, :last_name, :username, :tag

  attribute :avatar_url do |user|
    if user.avatar.attached?
      Rails.application.routes.url_helpers.url_for(user.avatar)
    end
  end
end