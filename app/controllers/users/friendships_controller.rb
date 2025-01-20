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
# class FriendshipsController < ApplicationController
#   before_action :authenticate_user!

#   def index
#     @friends = current_user.friends
#     @pending_requests = Friendship.where(friend: current_user, status: 'pending')
#   end

#   def create
#     friend = User.find(params[:friend_id])
#     if current_user.add_friend(friend)
#       redirect_to friendships_path, notice: 'Friend request sent.'
#     else
#       redirect_to friendships_path, alert: 'Unable to send friend request.'
#     end
#   end

#   def update
#     friend = User.find(params[:id])
#     if params[:status] == 'accept'
#       current_user.accept_friendship(friend)
#       redirect_to friendships_path, notice: 'Friend request accepted.'
#     elsif params[:status] == 'decline'
#       current_user.decline_friendship(friend)
#       redirect_to friendships_path, notice: 'Friend request declined.'
#     end
#   end
# end