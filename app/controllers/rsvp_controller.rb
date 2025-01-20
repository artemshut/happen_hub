class RsvpsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  # POST /groups/:group_id/events/:event_id/rsvps
  def create
    @rsvp = @event.rsvps.new(user: current_user, status: rsvp_params[:status])
    if @rsvp.save
      redirect_to group_event_path(@event.group, @event), notice: 'RSVP created successfully.'
    else
      redirect_to group_event_path(@event.group, @event), alert: 'Unable to RSVP.'
    end
  end

  # PATCH/PUT /groups/:group_id/events/:event_id/rsvps/:id
  def update
    @rsvp = @event.rsvps.find_by(user: current_user)
    if @rsvp.update(status: rsvp_params[:status])
      redirect_to group_event_path(@event.group, @event), notice: 'RSVP updated successfully.'
    else
      redirect_to group_event_path(@event.group, @event), alert: 'Unable to update RSVP.'
    end
  end

  # DELETE /groups/:group_id/events/:event_id/rsvps/:id
  def destroy
    @rsvp = @event.rsvps.find_by(user: current_user)
    if @rsvp&.destroy
      redirect_to group_event_path(@event.group, @event), notice: 'RSVP removed successfully.'
    else
      redirect_to group_event_path(@event.group, @event), alert: 'Unable to remove RSVP.'
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def rsvp_params
    params.require(:rsvp).permit(:status)
  end
end
