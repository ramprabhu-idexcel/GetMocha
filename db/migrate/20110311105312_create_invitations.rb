class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :project_id
      t.string :name, :limit => 40
      t.string :email, :limit => 100
      t.string :invitation_code, :limit => 40
      t.text :message
      t.timestamps
    end
     add_index "invitations", :project_id
  end

  def self.down
    drop_table :invitations
  end
end
