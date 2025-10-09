class Api::V1::EventCategoriesController < Api::V1::BaseController
  before_action :set_event_category, only: [ :show ]

  skip_before_action :authenticate_api_user!, only: [ :index, :show ]

  def index
    categories = policy_scope(EventCategory).order(:name)
    render json: EventCategorySerializer.new(categories).serializable_hash
  end

  def show
    authorize @event_category
    render json: EventCategorySerializer.new(@event_category).serializable_hash
  end

  private

  def set_event_category
    @event_category = EventCategory.find(params[:id])
  end
end
