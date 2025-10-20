ActiveAdmin.register EventSuggestion do
  permit_params :event_id, :user_id, :suggested_start_time, :suggested_end_time, :status

  includes :event, :user

  index do
    selectable_column
    id_column
    column :event
    column :user
    column :suggested_start_time
    column :suggested_end_time
    column :status
    column :created_at
    actions
  end

  filter :event
  filter :user
  filter :status, as: :select, collection: EventSuggestion.statuses.keys
  filter :suggested_start_time
  filter :created_at

  form do |f|
    f.inputs do
      f.input :event
      f.input :user
      f.input :suggested_start_time, as: :datetime_picker
      f.input :suggested_end_time, as: :datetime_picker
      f.input :status, as: :select, collection: EventSuggestion.statuses.keys
    end
    f.actions
  end
end
