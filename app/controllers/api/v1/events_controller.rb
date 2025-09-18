class Api::V1::EventsController < Api::V1::BaseController
  def index
    events = current_api_user.events
    render json: EventSerializer.new(events).serializable_hash
  end

  def show
    event = current_api_user.events.find_by(slug: params[:id])
    if event
      render json: EventSerializer.new(event).serializable_hash
    else
      render json: { error: 'Not found' }, status: :not_found
    end
  end
end