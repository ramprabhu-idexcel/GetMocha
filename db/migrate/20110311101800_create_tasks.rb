class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.integer :user_id
      t.integer :task_list_id
      t.string :name
      t.text :description
      t.date :due_date
      t.boolean :is_completed, :default => false
      t.integer :completed_by_id
      t.timestamps
    end
    add_index "tasks", :user_id
    add_index "tasks", :task_list_id
  end

  def self.down
    drop_table :tasks
  end
end
