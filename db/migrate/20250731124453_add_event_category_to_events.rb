class AddEventCategoryToEvents < ActiveRecord::Migration[8.0]
  def change
    add_reference :events, :event_category, null: false, foreign_key: true
  end
end
