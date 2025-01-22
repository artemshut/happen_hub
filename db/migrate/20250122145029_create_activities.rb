class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :action
      t.references :target, polymorphic: true, null: false
      t.json :metadata

      t.timestamps
    end
  end
end
