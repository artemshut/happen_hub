class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user! # 🔥 still protects web routes
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  # Devise extra fields
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name, :birthday, :username ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :birthday, :username ])
  end

  private

  def user_not_authorized
    respond_to do |format|
      format.html do
        redirect_to(request.referer || root_path, alert: "You are not authorized to perform that action.")
      end
      format.turbo_stream do
        flash[:alert] = "You are not authorized to perform that action."
        redirect_to(request.referer || root_path)
      end
      format.json { render json: { error: "forbidden" }, status: :forbidden }
    end
  end
end
