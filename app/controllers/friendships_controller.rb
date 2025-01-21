class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @friend = User.find(params[:friend_id])
    friendship = current_user.friendships.build(friend: @friend, status: :pending)

    if friendship.save
      redirect_to users_path, notice: "Friend request sent."
    else
      redirect_to users_path, alert: "Unable to send friend request."
    end
  end

  def update
    friendship = Friendship.find(params[:id])

    if params[:status] == "accepted"
      friendship.update(status: :accepted)
      redirect_to friendships_path, notice: "Friend request accepted."
    elsif params[:status] == "declined"
      friendship.update(status: :declined)
      redirect_to friendships_path, notice: "Friend request declined."
    else
      redirect_to friendships_path, alert: "Invalid action."
    end
  end

  def index
    @pending_requests = current_user.inverse_friendships.where(status: :pending)
    @friends = current_user.inverse_friendships.where(status: :accepted).map(&:user) + current_user.friendships.where(status: :accepted).map(&:friend)
  end
end
