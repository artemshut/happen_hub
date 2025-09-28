class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    if params[:id_token].present?
      # Mobile login flow
      validator = GoogleIDToken::Validator.new
      valid_client_ids = [
        "WEB_CLIENT_ID.apps.googleusercontent.com",     # happenhub client
        "521400701362-gilsbm87mrf4b500qafaalq7arsrapc5.apps.googleusercontent.com", # HappenHub Android
        "521400701362-9bj6galln7ff2g4l6oho1cdl54oh959n.apps.googleusercontent.com"      # HappenHub iOS
      ]

      payload = validator.check(params[:id_token], valid_client_ids)

      user = User.from_omniauth(payload)

      if user.persisted?
        token = JwtService.encode(user_id: user.id)
        render json: { token: token, user: UserSerializer.new(user) }, status: :ok
      else
        render json: { error: "Google login failed" }, status: :unauthorized
      end
    else
      # Web browser flow
      @user = User.from_omniauth(request.env["omniauth.auth"])

      if @user.persisted?
        @user.skip_confirmation_notification!
        @user.update(confirmed_at: Time.current) if @user.respond_to?(:confirmed_at) && @user.confirmed_at.nil?
        flash[:notice] = "Signed in successfully via Google."
        sign_in_and_redirect @user, event: :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"].except(:extra)
        redirect_to new_user_registration_url, alert: "Google sign-in failed."
      end
    end
  end

  def failure
    redirect_to root_path, alert: "Google sign-in failed."
  end
end
