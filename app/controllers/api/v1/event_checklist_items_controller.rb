class Api::V1::EventChecklistItemsController < Api::V1::BaseController
  before_action :set_event
  before_action :set_checklist
  before_action :authorize_event_read!, only: [ :index ]
  before_action :authorize_event_manage!, except: [ :index ]
  before_action :set_checklist_item, only: [ :update, :destroy, :toggle_complete, :reorder ]

  def index
    items = @checklist.items.includes(:assignee)
    render json: EventChecklistItemSerializer.new(items, params: serializer_params).serializable_hash
  end

  def create
    item = @checklist.items.new(checklist_item_params.merge(event: @event))
    if item.save
      render json: EventChecklistItemSerializer.new(item, params: serializer_params).serializable_hash, status: :created
    else
      render json: { errors: item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @checklist_item.update(checklist_item_params)
      render json: EventChecklistItemSerializer.new(@checklist_item, params: serializer_params).serializable_hash, status: :ok
    else
      render json: { errors: @checklist_item.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @checklist_item.destroy
    head :no_content
  end

  def toggle_complete
    @checklist_item.update(completed: !@checklist_item.completed?)
    render json: EventChecklistItemSerializer.new(@checklist_item, params: serializer_params).serializable_hash, status: :ok
  end

  def reorder
    target_position = params[:position].presence
    @checklist_item.reposition!(target_position.to_i) if target_position.present?
    render json: EventChecklistItemSerializer.new(@checklist_item.reload, params: serializer_params).serializable_hash, status: :ok
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_checklist
    @checklist = @event.checklists.find(params[:checklist_id])
  end

  def set_checklist_item
    @checklist_item = @checklist.items.find(params[:id])
  end

  def checklist_item_params
    params.require(:event_checklist_item).permit(:title, :due_at, :assignee_id, :completed, :position)
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
