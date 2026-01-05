class CreateEventChecklists < ActiveRecord::Migration[7.1]
  def up
    create_table :event_checklists do |t|
      t.references :event, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    create_table :event_checklist_items do |t|
      t.references :event, null: false, foreign_key: true
      t.references :event_checklist, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :due_at
      t.references :assignee, foreign_key: { to_table: :users }
      t.boolean :completed, default: false, null: false
      t.datetime :completed_at
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :event_checklists, [ :event_id, :position ]
    add_index :event_checklist_items, [ :event_checklist_id, :position ]
  end

  def down
    if index_exists?(:event_checklist_items, [ :event_checklist_id, :position ])
      remove_index :event_checklist_items, column: [ :event_checklist_id, :position ]
    end
    if index_exists?(:event_checklists, [ :event_id, :position ])
      remove_index :event_checklists, column: [ :event_id, :position ]
    end

    drop_table :event_checklist_items, if_exists: true
    drop_table :event_checklists, if_exists: true
  end
end
