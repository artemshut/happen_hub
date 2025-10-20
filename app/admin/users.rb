ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :tag, :first_name,
                :last_name, :birthday, :username, :provider, :uid, :fcm_token,
                :platform, :confirmed_at, :confirmation_token,
                :confirmation_sent_at, :unconfirmed_email, :remember_created_at

  includes :roles

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :tag
    column :first_name
    column :last_name
    column :created_at
    actions
  end

  filter :email
  filter :username
  filter :tag
  filter :first_name
  filter :last_name
  filter :provider
  filter :platform
  filter :created_at

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :first_name
      f.input :last_name
      f.input :username
      f.input :tag
      # f.input :birthday, as: :datepicker
      f.input :provider
      f.input :uid
      f.input :fcm_token
      f.input :platform
      f.input :confirmed_at, as: :datetime_picker
    end
    f.actions
  end
end
