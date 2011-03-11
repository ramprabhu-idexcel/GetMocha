class CreateCustomEmails < ActiveRecord::Migration
  def self.up
    create_table :custom_emails do |t|
      t.string :custom_type, :limit => 40
      t.integer :custom_id
      t.integer :project_id
      t.string :email, :limit => 100
      t.string :verification_code, :limit => 40
      t.timestamps
    end
     add_index "custom_emails", :custom_type
     add_index "custom_emails", :custom_id
     add_index "custom_emails", :project_id
  end

  def self.down
    drop_table :custom_emails
  end
end
