class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.integer :attachable_id
      t.string :attachable_type 
      t.string :content_type 
      t.string :filename
      t.integer :parent_id
      t.string :thumbnail
      t.integer :size
      t.integer :height
      t.integer :width
      t.timestamps
    end
     add_index "attachments", :attachable_id
     add_index "attachments", :attachable_type
     add_index "attachments", :parent_id
  end
 
  def self.down
    drop_table :attachments
  end
end
