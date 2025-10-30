class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    return redirect_to dashboard_path if user_signed_in?

    @landing_page = true
  end
end
