class FriendshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @friend = User.find(params[:friend_id])
    friendship = current_user.friendships.build(friend: @friend, status: :pending)

    if friendship.save
      redirect_to friendships_path, notice: "Friend request sent."
    else
      redirect_to friendships_path, alert: "Unable to send friend request."
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
    @invitations = current_user.inverse_friendships.where(status: :pending)
    @pending_requests = current_user.friendships.where(status: :pending)
    @friends = current_user.friends
  end

  def destroy
    friendship = current_user.friendships.find_by(friend_id: (params[:id]))
    friendship.destroy
    redirect_to friendships_path, notice: "Friend removed."
  end

  def search
    query = params[:q].downcase
    group_id = params[:group_id].presence
    existing_user_ids = group_id ? GroupMembership.where(group_id: group_id).pluck(:user_id) : []

    users = current_user.friendships.includes(:friend)
                        .where(status: "accepted")
                        .map(&:friend)
                        .reject { |user| existing_user_ids.include?(user.id) }
                        .select { |user| user.first_name.downcase.include?(query) || user.last_name.downcase.include?(query) }
                        .first(5)

    render json: users.map { |user| { id: user.id, full_name: "#{user.first_name} #{user.last_name}" } }
  end
end
