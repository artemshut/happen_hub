class Api::V1::TokensController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token

  def refresh
    refresh_token = params[:refresh_token]
    decoded = JwtService.decode(refresh_token)

    if decoded && decoded[:user_id]
      user = User.find_by(id: decoded[:user_id])
      if user
        access_token = JwtService.encode(user_id: user.id, exp: 24.hours.from_now)

        render json: {
          data: {
            type: "session",
            attributes: { token: access_token }
          }
        }, status: :ok
      else
        render json: { errors: [{ detail: "User not found" }] }, status: :unauthorized
      end
    else
      render json: { errors: [{ detail: "Invalid refresh token" }] }, status: :unauthorized
    end
  end
end