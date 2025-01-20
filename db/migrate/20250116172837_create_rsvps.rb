class CreateRsvps < ActiveRecord::Migration[8.0]
  def change
    create_table :rsvps do |t|
      t.integer :event_id
      t.integer :user_id
      t.string :status

      t.timestamps
    end
  end
end
