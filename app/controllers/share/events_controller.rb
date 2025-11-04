module Share
  class EventsController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: :track
    before_action :set_event

    helper EventsHelper

    def show
      @event.increment_share_views!
    end

    def track
      @event.increment_share_clicks!
      head :ok
    end

    private

    def set_event
      @event = Event.find_by!(share_token: params[:token])
    end
  end
end
