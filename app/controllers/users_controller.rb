class UsersController < ApplicationController
  before_action :authenticate_user!

  # GET /dashboard
  def dashboard
    @user = current_user
    @friends = @user.friends
    @groups = @user.groups
    @events = @user.events
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
