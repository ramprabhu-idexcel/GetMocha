class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :project_id
      t.integer :user_id
      t.string :subject, :limit => 255
      t.text :message
      t.timestamps
    end
    add_index "messages", :project_id
    add_index "messages", :user_id
  end

  def self.down
    drop_table :messages
  end
end
