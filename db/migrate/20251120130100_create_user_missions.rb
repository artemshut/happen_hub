class CreateUserMissions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_missions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :mission, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.integer :progress, null: false, default: 0
      t.integer :target_value, null: false, default: 1
      t.datetime :expires_at
      t.datetime :completed_at
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :user_missions, [ :user_id, :mission_id, :status ], name: "index_user_missions_on_user_and_mission_and_status"
  end
end
