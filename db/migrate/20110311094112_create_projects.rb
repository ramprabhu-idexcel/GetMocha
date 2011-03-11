class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name, :limit=>40
      t.integer :owner_id
      t.integer :status
      t.boolean :is_public
      t.string :message_email_id, :limit=>100
      t.string :task_email_id, :limit=>100
      t.timestamps
    end
    add_index "projects", :owner_id
  end
 
  def self.down
    drop_table :projects
  end
end
