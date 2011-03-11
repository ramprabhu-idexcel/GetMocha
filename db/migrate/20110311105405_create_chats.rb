class CreateChats < ActiveRecord::Migration
  def self.up
    create_table :chats do |t|
      t.integer :project_id
      t.integer :user_id
      t.text :message
      t.timestamps
    end
     add_index "chats", :project_id
     add_index "chats", :user_id
  end

  def self.down
    drop_table :chats
  end
end
