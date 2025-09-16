class UsersController < ApplicationController
  def dashboard
    @user = current_user
    @friends = @user.friends
    @groups = @user.groups
    @events = @user.owned_events
    @friend_activities = Activity.for_friends(current_user).recent
    @upcoming_events = Event.upcoming(current_user)
    @past_events = Event.past(current_user).limit(5)
    @pending_invitations = current_user.event_participations.where(rsvp_status: :pending)
    @total_events = @upcoming_events.count
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
      redirect_to dashboard_path, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def search
    @users = if params[:q].present?
      User.where("tag ILIKE ?", "%#{params[:q]}%")
          .where.not(id: current_user.id)
          .where.not(id: current_user.friends.pluck(:id))
    else
      []
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "search_results",
          partial: "users/search_results",
          locals: { users: @users }
        )
      end

      format.html do
        # Fallback (needed if accessed directly)
        render partial: "users/search_results", locals: { users: @users }, layout: false
      end
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :birthday, :cropped_avatar, :avatar)
  end
end
