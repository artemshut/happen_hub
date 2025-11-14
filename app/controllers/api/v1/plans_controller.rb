class Api::V1::PlansController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: :index
  before_action :assign_optional_api_user, only: :index

  def index
    plans = Plan.ordered_for_display

    render json: PlanSerializer.new(
      plans,
      params: { current_plan_id: current_api_user&.plan_id }
    ).serializable_hash
  end

  private

  def assign_optional_api_user
    header = request.headers["Authorization"]
    return if header.blank?

    token = header.split(" ").last
    decoded = JwtService.decode(token)
    @current_api_user = User.find_by(id: decoded[:user_id]) if decoded
  rescue JWT::DecodeError, ActiveSupport::MessageVerifier::InvalidSignature
    # Ignore invalid tokens for public endpoint
    @current_api_user = nil
  end
end
