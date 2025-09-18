class LikeSerializer
  include JSONAPI::Serializer

  set_type :like
  attributes :created_at

  belongs_to :user
end
