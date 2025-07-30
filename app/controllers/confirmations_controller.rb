class ConfirmationsController < ApplicationController
  def show
    user = User.find_by(confirmation_token: params[:confirmation_token])

    if user.present? && user.confirmation_period_valid?
      user.confirm
      UserMailer.welcome_email(user).deliver_now

      redirect_to root_path, notice: "Your email has been confirmed!"
    else
      redirect_to root_path, alert: "Invalid or expired confirmation link."
    end
  end
end
