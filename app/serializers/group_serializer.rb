class GroupSerializer
  include JSONAPI::Serializer

  attributes :id, :name, :description, :created_at, :updated_at

  attribute :creator_id do |group|
    group.user_id
  end

  has_many :members, serializer: UserSerializer
end
