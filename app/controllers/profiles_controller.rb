class ProfilesController < ApplicationController
  
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

  def avatar
    current_user.avatar.purge if current_user.avatar.attached?
    current_user.avatar.attach(params[:user][:cropped_avatar])
    redirect_to edit_profile_path(current_user), notice: "Avatar updated"
  end
  

  private

  def profile_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :avatar, :birthday)
  end
end
