class AddActionToActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :activities, :action, :integer
  end
end
