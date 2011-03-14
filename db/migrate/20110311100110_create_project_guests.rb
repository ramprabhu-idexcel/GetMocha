class CreateProjectGuests < ActiveRecord::Migration
  def self.up
    create_table :project_guests do |t|
      t.integer :guest_id
      t.integer :project_id
      t.boolean :status,:default=>true
      t.timestamps
    end
    add_index "project_guests", :guest_id
    add_index "project_guests", :project_id    
  end

  def self.down
    drop_table :project_guests
  end
end
