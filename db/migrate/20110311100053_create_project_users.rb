class CreateProjectUsers < ActiveRecord::Migration
  def self.up
    create_table :project_users do |t|
      t.integer :user_id
      t.integer :project_id
      t.boolean :status,:default=>true
      t.timestamps
    end
    add_index "project_users", :user_id
    add_index "project_users", :project_id
  end

  def self.down
    drop_table :project_users
  end
end
