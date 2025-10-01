class AddFcmTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :fcm_token, :string
    add_column :users, :platform, :string
  end
end
