class Api::V1::EventsController < ApplicationController
  before_action :authenticate_api_user!

  def index
    events = current_api_user.events
    render json: events, each_serializer: EventSerializer
  end

  def show
    event = current_api_user.events.find_by(slug: params[:id])
    if event
      render json: event, serializer: EventSerializer
    else
      render json: { error: 'Not found' }, status: :not_found
    end
  end
end