class Api::V1::MissionsController < Api::V1::BaseController
  def index
    authorize Mission
    user_missions = current_api_user.user_missions.includes(:mission)

    render json: UserMissionSerializer.new(
      user_missions,
      params: { current_user: current_api_user }
    ).serializable_hash
  end

  def update
    mission = current_api_user.user_missions.find(params[:id])
    authorize mission

    if mission.completed?
      render json: UserMissionSerializer.new(mission).serializable_hash
    else
      head :unprocessable_entity
    end
  end
end
