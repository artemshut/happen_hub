class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :username, :first_name, :last_name, :tag, :birthday
end