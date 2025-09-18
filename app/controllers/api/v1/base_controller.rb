class Api::V1::BaseController < ActionController::API
  before_action :authenticate_api_user!

  private

  def authenticate_api_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header.present?
    decoded = JwtService.decode(token)
    @current_api_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_api_user
  end

  def current_api_user
    @current_api_user
  end
end