class PagesController < ActionController::Base
  skip_before_action :authenticate_user!
  
  def accept_cookies
    cookies[:consent_given] = { value: "1", expires: 1.year.from_now }
    redirect_back fallback_location: root_path
  end

  def privacy_policy
  end

  def terms_of_service
    @title = "Terms of Service"
    render layout: "static"
  end
end  