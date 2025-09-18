class Api::V1::SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      access_token = JwtService.encode(user_id: user.id, exp = 24.hours.from_now)
      refresh_token = JwtService.encode(user_id: user.id, exp = 7.days.from_now)

      render json: {
        token: access_token,
        refresh_token: refresh_token,
        user: UserSerializer.new(user)
      }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end