# app/controllers/api/v1/events_controller.rb
class Api::V1::EventsController < Api::V1::BaseController
  before_action :authenticate_api_user!
  before_action :set_event, only: [:show]

  # GET /api/v1/events
  def index
    events = if params[:past] == "true"
               Event.past(current_api_user).includes(:event_category, :user)
             else
               Event.upcoming(current_api_user).includes(:event_category, :user)
             end

    events = events.where(event_category_id: params[:category_id]) if params[:category_id].present?
    events = events.order(start_time: :asc)

    render json: EventSerializer.new(events, include: [:user, :event_category, :comments, :"comments.user", :participants]).serializable_hash
  end

  # GET /api/v1/events/:id
  def show
    render json: EventSerializer.new(
      @event,
      include: [:user, :event_category, :comments, :likes, :event_participations, :comments, :"comments.user", :participants]
    ).serializable_hash
  end

  private

  def set_event
    @event = Event.friendly.find(params[:id])
  end
end