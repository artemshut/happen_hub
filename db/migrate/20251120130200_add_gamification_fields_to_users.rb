class AddGamificationFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :xp, :integer, null: false, default: 0
    add_column :users, :cosmetic_unlocks, :jsonb, null: false, default: {}
    add_index :users, :xp
  end
end
