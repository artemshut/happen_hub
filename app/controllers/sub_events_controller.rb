class SubEventsController < ApplicationController
  before_action :set_event
  before_action :authorize_event
  before_action :set_sub_event, only: %i[show edit update destroy]

  def new
    @sub_event = @event.sub_events.build
    render partial: "sub_events/form",
           locals: {
             event: @event,
             sub_event: @sub_event,
             frame_id: "new_sub_event",
             wrap_in_item: false,
             cancel_path: new_button_event_sub_events_path(@event)
           }
  end

  def new_button
    render partial: "sub_events/new_button", locals: { event: @event }
  end

  def show
    respond_to do |format|
      format.html { render :show, layout: false }
      format.turbo_stream { render partial: "sub_events/card", locals: { event: @event, sub_event: @sub_event } }
    end
  end

  def create
    @sub_event = @event.sub_events.build(sub_event_params)

    respond_to do |format|
      if @sub_event.save
        format.turbo_stream { render_timeline_refresh }
        format.html { redirect_to event_path(@event), notice: "Segment added." }
      else
        format.turbo_stream { render partial: "sub_events/form", status: :unprocessable_entity, locals: { event: @event, sub_event: @sub_event } }
        format.html { redirect_to event_path(@event), alert: @sub_event.errors.full_messages.to_sentence }
      end
    end
  end

  def edit
    render partial: "sub_events/form", locals: { event: @event, sub_event: @sub_event }
  end

  def update
    respond_to do |format|
      if @sub_event.update(sub_event_params)
        format.turbo_stream { render_timeline_refresh }
        format.html { redirect_to event_path(@event), notice: "Segment updated." }
      else
        format.turbo_stream { render partial: "sub_events/form", status: :unprocessable_entity, locals: { event: @event, sub_event: @sub_event } }
        format.html { redirect_to event_path(@event), alert: @sub_event.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    @sub_event.destroy

    respond_to do |format|
      format.turbo_stream { render_timeline_refresh }
      format.html { redirect_to event_path(@event), notice: "Segment removed." }
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def authorize_event
    authorize @event
  end

  def set_sub_event
    @sub_event = @event.sub_events.find(params[:id])
  end

  def sub_event_params
    params.require(:sub_event).permit(:title, :start_time, :end_time, :location, :notes, :position)
  end

  def render_timeline_refresh
    render turbo_stream: turbo_stream.replace(
      "sub_events_timeline_panel",
      partial: "events/sub_event_timeline",
      locals: { event: @event }
    )
  end
end
