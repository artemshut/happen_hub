ActiveAdmin.register Like do
  permit_params :user_id, :likeable_type, :likeable_id

  includes :user

  index do
    selectable_column
    id_column
    column :user
    column :likeable_type
    column :likeable_id
    column :created_at
    actions
  end

  filter :user
  filter :likeable_type
  filter :likeable_id
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :likeable_type
      f.input :likeable_id
    end
    f.actions
  end
end
