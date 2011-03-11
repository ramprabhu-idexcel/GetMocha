class CreateComments < ActiveRecord::Migration
  def self.up
   create_table :comments do |t|
     t.string :commentable_type, :limit => 40
     t.integer :commentable_id
     t.integer :user_id
     t.text :comment
     t.timestamps
   end
    add_index "comments", :user_id
  end

  def self.down
    drop_table :comments
  end
end
