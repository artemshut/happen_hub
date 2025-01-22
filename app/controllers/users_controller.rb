class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard
    @user = current_user
    @friends = @user.friends
    @groups = @user.groups
    @events = @user.events
    @friend_activities = Activity.for_friends(current_user).recent
    @upcoming_events = current_user.events.where('start_time >= ?', Time.current).order(:start_time)
    @pending_invitations = current_user.event_participations.where(rsvp_status: :pending)
    @total_events = current_user.events.count
    @total_groups = current_user.groups.count
    @total_friends = current_user.friends.count

  end

  # GET /profile/edit
  def edit
    @user = current_user
  end

  # PATCH/PUT /profile
  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to dashboard_path, notice: 'Profile updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :birthday)
  end
end
