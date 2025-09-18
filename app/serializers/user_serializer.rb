class UserSerializer
  include JSONAPI::Serializer
  
  set_type :user

  attributes :id, :email, :username, :first_name, :last_name, :tag, :birthday
end