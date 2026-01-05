class Api::V1::EventChecklistsController < Api::V1::BaseController
  before_action :set_event
  before_action :authorize_event_read!, only: [ :index, :show ]
  before_action :authorize_event_manage!, except: [ :index, :show ]
  before_action :set_checklist, only: [ :show, :update, :destroy, :reorder ]

  def index
    checklists = @event.checklists.includes(items: :assignee)
    render json: EventChecklistSerializer.new(checklists, params: serializer_params).serializable_hash
  end

  def show
    render json: EventChecklistSerializer.new(@checklist, params: serializer_params).serializable_hash
  end

  def create
    checklist = @event.checklists.new(checklist_params)
    if checklist.save
      render json: EventChecklistSerializer.new(checklist, params: serializer_params).serializable_hash, status: :created
    else
      render json: { errors: checklist.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @checklist.update(checklist_params)
      render json: EventChecklistSerializer.new(@checklist, params: serializer_params).serializable_hash, status: :ok
    else
      render json: { errors: @checklist.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @checklist.destroy
    head :no_content
  end

  def reorder
    @checklist.reposition!(params[:position]) if params[:position].present?
    render json: EventChecklistSerializer.new(@checklist.reload, params: serializer_params).serializable_hash, status: :ok
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_checklist
    @checklist = @event.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:event_checklist).permit(:title)
  end

  def authorize_event_read!
    authorize @event, :show?
  end

  def authorize_event_manage!
    authorize @event, :update?
  end

  def serializer_params
    { host: request.base_url }
  end
end
