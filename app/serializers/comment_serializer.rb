class CommentSerializer
  include JSONAPI::Serializer

  set_type :comment
  attributes :content, :created_at

  belongs_to :user
end