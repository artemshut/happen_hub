class Api::V1::SessionsController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token
  
  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      access_token = JwtService.encode(user_id: user.id, exp: 24.hours.from_now)
      refresh_token = JwtService.encode(user_id: user.id, exp: 7.days.from_now)

      render json: {
        data: {
          type: "session",
          attributes: {
            token: access_token,
            refresh_token: refresh_token
          },
          relationships: {
            user: {
              data: { id: user.id.to_s, type: "user" }
            }
          }
        },
        included: [
          UserSerializer.new(user).serializable_hash[:data]
        ]
      }, status: :ok
    else
      render json: {
        errors: [{ detail: "Invalid email or password" }]
      }, status: :unauthorized
    end
  end
end