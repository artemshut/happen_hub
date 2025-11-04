# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User sessions", type: :request do
  describe "GET /users/sign_in" do
    it "stores the provided return_to location for the user scope" do
      user = create(:user)
      event = create(:event, user: user)

      get new_user_session_path(return_to: event_path(event))

      expect(session["user_return_to"]).to eq(event_path(event))
    end
  end

  describe "POST /users/sign_in" do
    it "redirects to the stored return location after authentication" do
      user = create(:user)
      event = create(:event, user: user)

      get new_user_session_path(return_to: event_path(event))

      post user_session_path,
        params: {
          user: {
            email: user.email,
            password: "password123"
          }
        }

      expect(response).to redirect_to(event_path(event))
    end
  end
end
