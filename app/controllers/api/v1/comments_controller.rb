class Api::V1::CommentsController < Api::V1::BaseController
  skip_before_action :authenticate_api_user!, only: [:index]
  before_action :set_event
  before_action :ensure_event_visible!
  before_action :set_comment, only: [:destroy]

  def index
    comments = @event.comments.includes(:user).order(created_at: :asc)

    render json: CommentSerializer.new(comments, params: serializer_params).serializable_hash
  end

  def create
    comment = @event.comments.build(comment_params.merge(user: current_api_user))
    authorize comment

    if comment.save
      render json: CommentSerializer.new(comment, params: serializer_params).serializable_hash,
             status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @comment

    @comment.destroy
    head :no_content
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_comment
    @comment = @event.comments.find(params[:id])
  end

  def ensure_event_visible!
    visible = EventPolicy.new(current_api_user, @event).show?
    return if visible

    render json: { error: "forbidden" }, status: :forbidden
  end

  def comment_params
    params.require(:comment).permit(:content)
  end

  def serializer_params
    { host: request.base_url }
  end
end
