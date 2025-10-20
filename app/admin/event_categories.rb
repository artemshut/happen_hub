ActiveAdmin.register EventCategory do
  permit_params :name, :emoji, :description

  index do
    selectable_column
    id_column
    column :name
    column :emoji
    column :description
    column :created_at
    actions
  end

  filter :name
  filter :emoji
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :emoji
      f.input :description
    end
    f.actions
  end
end
