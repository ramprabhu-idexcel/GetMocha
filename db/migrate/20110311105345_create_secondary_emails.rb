class CreateSecondaryEmails < ActiveRecord::Migration
  def self.up
    create_table :secondary_emails do |t|
      t.integer :user_id
      t.string :email, :limit => 100
      t.string :confirmation_token, :limit => 40
      t.timestamps
    end
     add_index "secondary_emails", :user_id
  end

  def self.down
    drop_table :secondary_emails
  end
end
