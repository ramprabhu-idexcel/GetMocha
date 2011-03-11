class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :resource_type, :limit=>40
      t.integer :resource_id
      t.integer :user_id
      t.boolean :is_starred
      t.boolean :is_subscribed
      t.boolean :is_assigned
      t.boolean :is_reed
      t.boolean :is_delete
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
