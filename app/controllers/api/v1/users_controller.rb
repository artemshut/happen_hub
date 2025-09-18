class Api::V1::UsersController < Api::V1::BaseController
  def me
    render json: UserSerializer.new(current_api_user).serializable_hash, status: :ok
  end
end