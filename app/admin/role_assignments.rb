ActiveAdmin.register RoleAssignment do
  permit_params :user_id, :role_id, :resource_type, :resource_id

  includes :user, :role

  index do
    selectable_column
    id_column
    column :user
    column :role
    column :resource_type
    column :resource_id
    column :created_at
    actions
  end

  filter :user
  filter :role
  filter :resource_type
  filter :resource_id
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :role
      f.input :resource_type
      f.input :resource_id
    end
    f.actions
  end
end
