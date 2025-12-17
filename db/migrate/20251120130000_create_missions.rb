class CreateMissions < ActiveRecord::Migration[7.1]
  def change
    create_table :missions do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.text :description
      t.string :category, null: false, default: "weekend"
      t.integer :target_value, null: false, default: 1
      t.integer :reward_xp, null: false, default: 0
      t.string :reward_badge
      t.boolean :auto_assign, null: false, default: true
      t.boolean :active, null: false, default: true
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :missions, :key, unique: true
  end
end
