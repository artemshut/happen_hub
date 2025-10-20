ActiveAdmin.register Group do
  permit_params :name, :description, :user_id

  includes :user

  index do
    selectable_column
    id_column
    column :name
    column :user
    column :created_at
    actions
  end

  filter :name
  filter :user
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :user
    end
    f.actions
  end
end
