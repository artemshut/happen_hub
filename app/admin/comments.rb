ActiveAdmin.register Comment, as: "UserComment" do
  permit_params :user_id, :event_id, :content

  includes :user, :event

  index do
    selectable_column
    id_column
    column :user
    column :event
    column :content
    column :created_at
    actions
  end

  filter :user
  filter :event
  filter :content
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :event
      f.input :content
    end
    f.actions
  end
end
