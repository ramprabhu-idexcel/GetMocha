class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :resource_type, :limit=>40
      t.integer :resource_id
      t.integer :user_id
      t.boolean :is_starred,:default=>false
      t.boolean :is_subscribed,:default=>false
      t.boolean :is_assigned,:default=>false
      t.boolean :is_read,:default=>false
      t.boolean :is_delete,:default=>false
      t.timestamps
    end
    add_index "activities", :resource_type
    add_index "activities", :resource_id
    add_index "activities", :user_id
  end

  def self.down
    drop_table :activities
  end
end
