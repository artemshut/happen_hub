class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event

  def create
    @comment = @event.comments.build(comment_params)
    @comment.user = current_user
  
    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to event_path(@event), notice: 'Comment added successfully.' }
      end
    else
      flash.now[:alert] = "Comment can't be blank."
      render 'events/show', status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
