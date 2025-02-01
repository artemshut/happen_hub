class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: %i[show edit update destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # GET /groups
  def index
    @groups = current_user.groups
  end

  # GET /groups/:id
  def show
    @members = @group.users
  end

  # GET /groups/new
  def new
    @group = current_user.groups.new
    @friends = current_user.inverse_friendships.where(status: :accepted).map(&:user) + current_user.friendships.where(status: :accepted).map(&:friend)
  end

  # POST /groups
  def create
    @group = current_user.groups.new(group_params)
    @group.user = current_user
    @group.group_memberships.build(user: current_user)
    if @group.save
      add_friends_to_group
      redirect_to @group, notice: 'Group created successfully.'
    else
      @friends = current_user.friends
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:id/edit
  def edit
    @friends = current_user.inverse_friendships.where(status: :accepted).map(&:user) + current_user.friendships.where(status: :accepted).map(&:friend)
  end

  # PATCH/PUT /groups/:id
  def update
    if @group.update(group_params)
      update_group_friends
      redirect_to group_path(@group), notice: 'Group updated successfully.'
    else
      @friends = current_user.friends
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:id
  def destroy
    @group.destroy
    redirect_to groups_path, notice: 'Group deleted successfully.'
  end

  def add_friend
    friend = User.find(params[:friend_id])
    if group.add_friend(friend)
      redirect_to group_path(group), notice: 'Friend added to the group.'
    else
      redirect_to group_path(group), alert: 'Unable to add friend to the group.'
    end
  end

  private

  def set_group
    @group = Group.find(params[:id])
  end

  def authorize_user!
    redirect_to groups_path, alert: 'Not authorized.' unless @group.user == current_user
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end

  def add_friends_to_group
    return unless params[:group][:friend_ids]

    friend_ids = params[:group][:friend_ids].reject(&:blank?)
    friend_ids.each do |friend_id|
      @group.add_friend(User.find(friend_id))
    end
  end

  def update_group_friends
    return unless params[:group][:user_ids]
  
    new_user_ids = params[:group][:user_ids].reject(&:blank?).map(&:to_i)
    existing_user_ids = @group.group_memberships.pluck(:user_id)
  
    # Find users to add (new ones)
    users_to_add = new_user_ids - existing_user_ids
    users_to_add.each do |user_id|
      @group.group_memberships.create(user_id: user_id)
    end
  
    # Find users to remove (users that were unchecked)
    users_to_remove = existing_user_ids - new_user_ids
    users_to_remove.each do |user_id|
      @group.group_memberships.find_by(user_id: user_id)&.destroy
    end
  end
  
end
