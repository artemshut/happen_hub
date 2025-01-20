class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  # GET /friends
  def index
    @friends = current_user.friends
  end

  # POST /friends
  def create
    friend = User.find_by(tag: params[:tag])
    if friend && current_user != friend
      current_user.friendships.create(friend: friend)
      redirect_to friends_path, notice: "Friend added successfully."
    else
      redirect_to friends_path, alert: "Unable to add friend. Please check the tag."
    end
  end

  # DELETE /friends/:id
  def destroy
    friendship = current_user.friendships.find_by(friend_id: params[:id])
    if friendship
      friendship.destroy
      redirect_to friends_path, notice: "Friend removed successfully."
    else
      redirect_to friends_path, alert: "Friend not found."
    end
  end
end
