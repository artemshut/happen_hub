class Api::V1::UsersController < Api::V1::BaseController
  def me
    render json: UserSerializer.new(current_api_user).serializable_hash, status: :ok
  end

  def update_fcm_token
    attrs = fcm_token_attributes
    return unless attrs

    if current_api_user.update(attrs)
      render json: { success: true, fcm_token: current_api_user.fcm_token, platform: current_api_user.platform }, status: :ok
    else
      render json: { success: false, errors: current_api_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def fcm_token_attributes
    permitted = params.permit(:fcm_token, :token, :apns_token, :platform)
    token = permitted[:token].presence || permitted[:fcm_token].presence || permitted[:apns_token].presence

    unless token
      render json: { success: false, errors: [ "FCM token is required" ] }, status: :unprocessable_entity
      return
    end

    platform = permitted[:platform].presence&.downcase
    unless platform.nil? || %w[ios android web].include?(platform)
      render json: { success: false, errors: [ "platform must be ios, android, or web" ] }, status: :unprocessable_entity
      return
    end

    attrs = { fcm_token: token }
    attrs[:platform] = platform if platform.present?
    attrs
  end
end
