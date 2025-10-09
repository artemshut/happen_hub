class PublicProfilesController < ApplicationController
  before_action :find_user

  def show
    @is_friend = current_user&.friends_with?(@user)
    @request_sent = current_user&.friend_request_sent_to?(@user)
  end

  def add_friend
    if current_user.nil?
      redirect_to new_user_session_path, alert: "Log in to send a friend request."
    elsif current_user == @user
      redirect_to public_profile_path(@user.username), alert: "You can't add yourself."
    else
      current_user.send_friend_request_to(@user)
      redirect_to public_profile_path(@user.username), notice: "Friend request sent!"
    end
  end

  private

  def find_user
    @user = User.find_by!(username: params[:username])
  end
end
