ActiveAdmin.register Event do
  permit_params :title, :description, :start_time, :end_time, :location,
                :group_id, :user_id, :visibility, :latitude, :longitude,
                :event_category_id, :slug

  includes :user, :group, :event_category

  index do
    selectable_column
    id_column
    column :title
    column :user
    column :group
    column :event_category
    column :start_time
    column :end_time
    column :visibility
    column :created_at
    actions
  end

  filter :title
  filter :user
  filter :group
  filter :event_category
  filter :visibility, as: :select, collection: Event.visibilities.keys
  filter :start_time
  filter :created_at

  form do |f|
    f.inputs do
      f.input :title
      f.input :user
      f.input :group
      f.input :event_category
      f.input :description
      f.input :start_time, as: :datetime_picker
      f.input :end_time, as: :datetime_picker
      f.input :location
      f.input :visibility, as: :select, collection: Event.visibilities.keys
      f.input :latitude
      f.input :longitude
      f.input :slug
    end
    f.actions
  end
end
