class Api::V1::UsersController < Api::V1::BaseController
  def me
    render json: UserSerializer.new(current_api_user).serializable_hash, status: :ok
  end

  def update_fcm_token
    if current_api_user.update(fcm_token: params[:fcm_token], platform: params[:platform])
      render json: { success: true, fcm_token: current_api_user.fcm_token, platform: current_api_user.platform }, status: :ok
    else
      render json: { success: false, errors: current_api_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
