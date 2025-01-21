class CreateEventSuggestions < ActiveRecord::Migration[8.0]
  def change
    create_table :event_suggestions do |t|
      t.references :event, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :suggested_start_time
      t.datetime :suggested_end_time
      t.string :status

      t.timestamps
    end
  end
end
