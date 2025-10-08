class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.string :key, null: false
      t.text :description

      t.timestamps
    end

    add_index :roles, :key, unique: true

    create_table :role_assignments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :resource, polymorphic: true

      t.timestamps
    end

    add_index :role_assignments,
              [:user_id, :role_id, :resource_type, :resource_id],
              unique: true,
              name: "idx_role_assignments_unique"
  end
end
