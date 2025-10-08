class Api::EventsController < ApplicationController
  def index
    authorize Event

    events = Event.visible_to(current_user).includes(:event_participations, :users)

    render json: events.map { |event| format_event(event) }
  end

  private

  def format_event(event)
    {
      id: event.id,
      title: event.title,
      start: event.start_time.iso8601,
      end: event.end_time.iso8601,
      url: event_path(event),
      extendedProps: {
        status: rsvp_status_for(event),
        color: event_color(rsvp_status_for(event)) # Include the color here
      }
    }
  end

  def rsvp_status_for(event)
    participation = event.event_participations.find { |part| part.user_id == current_user.id }
    participation&.rsvp_status
  end

  def event_color(status)
    case status
    when "accepted" then "#4caf50" # Green
    when "maybe" then "#ffeb3b" # Yellow
    when "declined" then "#f44336" # Red
    else "#9e9e9e" # Gray for no status
    end
  end
end
