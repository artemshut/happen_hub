class EventSuggestionsController < ApplicationController
  before_action :set_event
  before_action :authenticate_user!

  def create
    suggestion = @event.event_suggestions.build(suggestion_params)
    suggestion.user = current_user
    suggestion.status = :pending

    if suggestion.save
      redirect_to event_path(@event), notice: 'Suggestion submitted successfully.'
    else
      redirect_to event_path(@event), alert: 'Failed to submit the suggestion.'
    end
  end

  def update
    suggestion = @event.event_suggestions.find(params[:id])

    if params[:status] == 'approved'
      @event.update(start_time: suggestion.suggested_start_time, end_time: suggestion.suggested_end_time)
      suggestion.update(status: :approved)
      @event.event_suggestions.where.not(id: suggestion.id).update_all(status: :rejected)
      redirect_to event_path(@event), notice: 'Event updated with the suggested time.'
    elsif params[:status] == 'rejected'
      suggestion.update(status: :rejected)
      redirect_to event_path(@event), notice: 'Suggestion rejected.'
    else
      redirect_to event_path(@event), alert: 'Invalid status update.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def suggestion_params
    params.require(:event_suggestion).permit(:suggested_start_time, :suggested_end_time)
  end
end
