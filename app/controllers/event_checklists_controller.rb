class EventChecklistsController < ApplicationController
  before_action :set_event
  before_action :authorize_event
  before_action :set_checklist, only: %i[show edit update destroy reorder]

  def show
    render_checklist
  end

  def edit
    render_checklist_form
  end

  def create
    @checklist = @event.checklists.new(checklist_params)
    if @checklist.save
      render_checklists_panel(status: :created, notice: "Checklist created.")
    else
      render_checklists_panel(status: :unprocessable_entity, checklist_form: @checklist)
    end
  end

  def update
    if @checklist.update(checklist_params)
      render_checklist
    else
      render_checklist_form(status: :unprocessable_entity)
    end
  end

  def destroy
    @checklist.destroy
    render_checklists_panel(notice: "Checklist removed.")
  end

  def reorder
    @checklist.reposition!(params[:position]) if params[:position].present?
    render_checklists_panel
  end

  private

  def set_event
    @event = Event.includes(checklists: { items: :assignee }).friendly.find(params[:event_id])
  end

  def authorize_event
    authorize(@event, :update?)
  end

  def set_checklist
    @checklist = @event.checklists.find(params[:id])
  end

  def checklist_params
    params.require(:event_checklist).permit(:title)
  end

  def render_checklists_panel(status: :ok, notice: nil, checklist_form: nil)
    refresh_event!
    form_object = checklist_form || EventChecklist.new(event: @event)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "event_checklists_panel",
          partial: "events/checklists_section",
          locals: { event: @event, checklist_form: form_object }
        ), status: status
      end
      format.html { redirect_to event_path(@event), status: :see_other, notice: }
    end
  end

  def render_checklist(status: :ok)
    refresh_event!
    checklist = @event.checklists.find(@checklist.id)
    render html: render_to_string(
      partial: "events/checklist_panel",
      locals: { event: @event, checklist: checklist }
    ), status:
  end

  def render_checklist_form(checklist: @checklist, status: :ok)
    refresh_event!
    render html: render_to_string(
      partial: "events/checklist_form",
      locals: { event: @event, checklist: checklist }
    ), status:
  end

  def refresh_event!
    @event = Event.includes(checklists: { items: :assignee }).find(@event.id)
  end
end
