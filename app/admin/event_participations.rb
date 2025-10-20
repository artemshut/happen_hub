ActiveAdmin.register EventParticipation do
  permit_params :event_id, :user_id, :rsvp_status

  includes :event, :user

  index do
    selectable_column
    id_column
    column :event
    column :user
    column :rsvp_status
    column :created_at
    actions
  end

  filter :event
  filter :user
  filter :rsvp_status, as: :select, collection: EventParticipation.rsvp_statuses.keys
  filter :created_at

  form do |f|
    f.inputs do
      f.input :event
      f.input :user
      f.input :rsvp_status, as: :select, collection: EventParticipation.rsvp_statuses.keys
    end
    f.actions
  end
end
