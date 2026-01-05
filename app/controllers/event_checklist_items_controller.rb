class EventChecklistItemsController < ApplicationController
  before_action :set_event
  before_action :authorize_event
  before_action :set_checklist
  before_action :set_item, only: %i[show edit update destroy toggle_complete reorder]

  def show
    render_item
  end

  def edit
    render_item_form
  end

  def create
    @item = @checklist.items.new(item_params.merge(event: @event))
    if @item.save
      render_checklist_panel(status: :created)
    else
      render_checklist_panel(status: :unprocessable_entity, alert: @item.errors.full_messages.to_sentence)
    end
  end

  def update
    if @item.update(item_params)
      render_item
    else
      render_item_form(status: :unprocessable_entity)
    end
  end

  def destroy
    @item.destroy
    render_checklist_panel
  end

  def toggle_complete
    @item.update(completed: !@item.completed?)
    render_item
  end

  def reorder
    @item.reposition!(params[:position]) if params[:position].present?
    render_checklist_panel
  end

  private

  def set_event
    @event = Event.friendly.find(params[:event_id])
  end

  def set_checklist
    @checklist = @event.checklists.find(params[:checklist_id])
  end

  def authorize_event
    authorize(@event, :update?)
  end

  def set_item
    @item = @checklist.items.find(params[:id])
  end

  def item_params
    params.require(:event_checklist_item).permit(:title, :due_at, :assignee_id)
  end

  def render_checklist_panel(status: :ok, alert: nil)
    refresh_event!
    checklist = @event.checklists.find(@checklist.id)
    render html: render_to_string(
      partial: "events/checklist_panel",
      locals: { event: @event, checklist: checklist, alert_message: alert }
    ), status:
  end

  def render_item(status: :ok)
    refresh_event!
    checklist = @event.checklists.find(@checklist.id)
    item = checklist.items.find(@item.id)
    render html: render_to_string(
      partial: "events/checklist_item",
      locals: { event: @event, checklist:, item: }
    ), status:
  end

  def render_item_form(item: @item, status: :ok)
    refresh_event!
    checklist = @event.checklists.find(@checklist.id)
    render html: render_to_string(
      partial: "events/checklist_item_form",
      locals: { event: @event, checklist:, item: item }
    ), status:
  end

  def refresh_event!
    @event = Event.includes(checklists: { items: :assignee }).find(@event.id)
  end
end
