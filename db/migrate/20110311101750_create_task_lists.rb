class CreateTaskLists < ActiveRecord::Migration
  def self.up
    create_table :task_lists do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :name
      t.timestamps
    end
    add_index "task_lists", :project_id
    add_index "task_lists", :user_id
  end

  def self.down
    drop_table :task_lists
  end
end
