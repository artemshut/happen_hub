class ApplicationController < ActionController::Base
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  def authenticate_api_user!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    decoded = JwtService.decode(token)
    @current_api_user = User.find_by(id: decoded[:user_id]) if decoded
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_api_user
  end

  def current_api_user
    @current_api_user
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :birthday, :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :birthday, :username ])
  end
end
