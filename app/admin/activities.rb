# ActiveAdmin.register Activity do
#   permit_params :user_id, :action, :target_type, :target_id, :metadata

#   includes :user

#   index do
#     selectable_column
#     id_column
#     column :user
#     column :action
#     column :target_type
#     column :target_id
#     column :created_at
#     actions
#   end

#   filter :user
#   filter :action, as: :select, collection: Activity.actions.keys
#   filter :target_type
#   filter :target_id
#   filter :created_at

#   form do |f|
#     f.inputs do
#       f.input :user
#       f.input :action, as: :select, collection: Activity.actions.keys
#       f.input :target_type
#       f.input :target_id
#       f.input :metadata
#     end
#     f.actions
#   end
# end
