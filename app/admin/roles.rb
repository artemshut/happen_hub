ActiveAdmin.register Role do
  permit_params :name, :key, :description

  index do
    selectable_column
    id_column
    column :name
    column :key
    column :description
    column :created_at
    actions
  end

  filter :name
  filter :key
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :key
      f.input :description
    end
    f.actions
  end
end
