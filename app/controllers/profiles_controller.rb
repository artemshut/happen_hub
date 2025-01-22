class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
  
    # Remove password fields if they're blank
    if profile_params[:password].blank? && profile_params[:password_confirmation].blank?
      filtered_params = profile_params.except(:password, :password_confirmation)
    else
      filtered_params = profile_params
    end
  
    if @user.update(filtered_params)
      redirect_to profile_path, notice: 'Profile updated successfully.'
    else
      flash.now[:alert] = 'Error updating profile.'
      render :edit, status: :unprocessable_entity
    end
  end
  

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end
end
