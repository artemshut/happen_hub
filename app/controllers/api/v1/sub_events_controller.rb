class Api::V1::SubEventsController < Api::V1::BaseController
  before_action :set_event
  before_action :set_sub_event, only: [ :show, :update, :destroy ]

  def index
    authorize @event, :show?
    render json: serialize(@event.sub_events)
  end

  def show
    authorize @event, :show?
    render json: serialize(@sub_event)
  end

  def create
    authorize @event, :update?
    sub_event = @event.sub_events.new(sub_event_params)

    if sub_event.save
      render json: serialize(sub_event), status: :created
    else
      render json: { errors: sub_event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @event, :update?

    if @sub_event.update(sub_event_params)
      render json: serialize(@sub_event), status: :ok
    else
      render json: { errors: @sub_event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @event, :update?
    @sub_event.destroy
    head :no_content
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_sub_event
    @sub_event = @event.sub_events.find(params[:id])
  end

  def sub_event_params
    params.require(:sub_event).permit(:title, :start_time, :end_time, :location, :notes, :position)
  end

  def serialize(resource)
    SubEventSerializer.new(resource).serializable_hash
  end
end
