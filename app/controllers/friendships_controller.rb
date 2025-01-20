class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @friends = current_user.friends
    @pending_requests = Friendship.where(friend: current_user, status: 'pending')
  end

  def create
    friend = User.find(params[:friend_id])
    if current_user.add_friend(friend)
      redirect_to friendships_path, notice: 'Friend request sent.'
    else
      redirect_to friendships_path, alert: 'Unable to send friend request.'
    end
  end

  def update
    friend = User.find(params[:id])
    if params[:status] == 'accept'
      current_user.accept_friendship(friend)
      redirect_to friendships_path, notice: 'Friend request accepted.'
    elsif params[:status] == 'decline'
      current_user.decline_friendship(friend)
      redirect_to friendships_path, notice: 'Friend request declined.'
    end
  end
end