class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization

  before_action :authenticate_api_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_api_user!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?
    decoded = JwtService.decode(token)
    @current_api_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_api_user
  end

  def current_api_user
    @current_api_user
  end

  def pundit_user
    current_api_user
  end

  def user_not_authorized
    render json: { error: "forbidden" }, status: :forbidden
  end
end
