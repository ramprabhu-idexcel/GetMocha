class CreateProjectGuests < ActiveRecord::Migration
  def self.up
    create_table :project_guests do |t|
      t.integer :user_id
      t.integer :project_id
      t.boolean :status
      t.timestamps
    end
    add_index "project_guests", :user_id
    add_index "project_guests", :project_id    
  end

  def self.down
    drop_table :project_guests
  end
end
