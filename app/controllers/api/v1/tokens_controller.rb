class Api::V1::TokensController < ApplicationController
  skip_before_action :authenticate_user!

  def refresh
    refresh_token = params[:refresh_token]
    payload = JwtService.decode(refresh_token)

    if payload && (user = User.find_by(id: payload[:user_id]))
      new_token = JwtService.encode({ user_id: user.id }, 24.hours.from_now)
      render json: { token: new_token }, status: :ok
    else
      render json: { error: 'Invalid refresh token' }, status: :unauthorized
    end
  end
end