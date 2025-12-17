class CreateSubEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :sub_events do |t|
      t.references :event, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.string :location
      t.text :notes
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :sub_events, [ :event_id, :position ]
    add_index :sub_events, [ :event_id, :start_time ]
  end
end
