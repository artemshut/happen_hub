ActiveAdmin.register GroupMembership do
  permit_params :group_id, :user_id

  includes :group, :user

  index do
    selectable_column
    id_column
    column :group
    column :user
    column :created_at
    actions
  end

  filter :group
  filter :user
  filter :created_at

  form do |f|
    f.inputs do
      f.input :group
      f.input :user
    end
    f.actions
  end
end
