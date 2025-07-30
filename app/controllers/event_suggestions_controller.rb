class EventSuggestionsController < ApplicationController
  before_action :set_event

  def create
    @suggestion = @event.event_suggestions.build(suggestion_params)
    @suggestion.user = current_user
    @suggestion.status = :pending

    if @suggestion.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @event, notice: "Suggestion added." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_event_suggestion", partial: "event_suggestions/form", locals: { event: @event, suggestion: @suggestion }) }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    @event = Event.find(params[:event_id])
    @suggestion = @event.event_suggestions.find(params[:id])

    params[:status] = params[:status].presence || "approved"
    case params[:status]
    when "approved"
      @event.update!(start_time: @suggestion.suggested_start_time, end_time: @suggestion.suggested_end_time)
      @suggestion.update!(status: :approved)
      @event.event_suggestions.where.not(id: @suggestion.id).update_all(status: :rejected)
    when "rejected"
      @suggestion.update!(status: :rejected)
    else
      head :unprocessable_entity
      return
    end
  
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @event, notice: "Updated" }
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
