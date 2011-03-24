class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name, :limit=>40
      t.integer :user_id
      t.integer :status
      t.boolean :is_public,:default=>true
      t.string :message_email_id, :limit=>100
      t.string :task_email_id, :limit=>100
      t.timestamps
    end
    add_index "projects", :user_id
  end
   def self.down
    drop_table :projects
  end
end
