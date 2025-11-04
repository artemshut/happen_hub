class AddShareFieldsToEvents < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  class Event < ApplicationRecord
    self.table_name = "events"
  end

  def up
    add_column :events, :share_token, :string
    add_column :events, :share_views, :integer, default: 0, null: false
    add_column :events, :share_clicks, :integer, default: 0, null: false

    add_index :events, :share_token, unique: true, algorithm: :concurrently

    Event.reset_column_information
    say_with_time "Backfilling event share tokens" do
      Event.find_each do |event|
        event.update_columns(share_token: SecureRandom.urlsafe_base64(12)) unless event.share_token.present?
      end
    end
  end

  def down
    remove_index :events, :share_token
    remove_column :events, :share_clicks
    remove_column :events, :share_views
    remove_column :events, :share_token
  end
end
