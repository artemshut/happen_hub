class PlansController < ApplicationController
  before_action :authenticate_user!, only: :activate

  def index
    @plans = Plan.ordered_for_display
    @current_plan = current_user&.plan
  end

  def activate
    plan = Plan.find(params[:id])

    if plan == current_user.plan
      redirect_to plans_path, notice: "You're already using the #{plan.name} plan."
      return
    end

    if downgrading_below_active_events?(plan)
      redirect_to plans_path, alert: "You currently host more active events than #{plan.name} allows. Wrap up or archive events before downgrading."
      return
    end

    current_user.update!(plan: plan)
    redirect_to plans_path, notice: "You're now rocking the #{plan.name} plan."
  end

  private

  def downgrading_below_active_events?(plan)
    return false if plan.unlimited_events? || current_user.active_events_count <= plan.max_active_events.to_i

    plan.max_active_events.present? && current_user.active_events_count > plan.max_active_events
  end
end
