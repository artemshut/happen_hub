class Api::EventsController < ApplicationController
  before_action :authenticate_user!

  def index
    events = Event.includes(:users)
    .where("events.user_id = ? OR event_participations.user_id = ?", current_user.id, current_user.id)
    .references(:event_participations)
    .select("events.*, event_participations.rsvp_status as status")
    
    render json: events.map { |event| format_event(event) }
  end

  private

  def format_event(event)
    {
      id: event.id,
      title: event.title,
      start: event.start_time.iso8601,
      end: event.end_time.iso8601,
      location: event_path(event),
      extendedProps: {
        status: event.status,
        color: event_color(event.status) # Include the color here
      }
    }
  end

  def event_color(status)
    case status
    when 'accepted' then '#4caf50' # Green
    when 'maybe' then '#ffeb3b' # Yellow
    when 'declined' then '#f44336' # Red
    else '#9e9e9e' # Gray for no status
    end
  end
end
