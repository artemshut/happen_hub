class CommentSerializer
  include JSONAPI::Serializer

  attributes :id, :content, :created_at

  belongs_to :user, serializer: UserSerializer
end
