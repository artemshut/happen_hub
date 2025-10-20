ActiveAdmin.register Friendship do
  permit_params :user_id, :friend_id, :status

  includes :user

  index do
    selectable_column
    id_column
    column :user
    column :friend
    column :status
    column :created_at
    actions
  end

  filter :user
  filter :friend
  filter :status, as: :select, collection: Friendship.statuses.keys
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :friend, collection: User.all
      f.input :status, as: :select, collection: Friendship.statuses.keys
    end
    f.actions
  end
end
