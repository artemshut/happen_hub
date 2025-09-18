class Api::V1::UsersController < ApplicationController
  before_action :authenticate_api_user!

  def me
    render json: UserSerializer.new(current_api_user).serializable_hash, status: :ok
  end
end