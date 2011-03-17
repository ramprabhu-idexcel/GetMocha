class AddStatusToInvitation < ActiveRecord::Migration
  def self.up
    add_column :invitations, :status, :boolean, :default=>false
  end

  def self.down
    remove_column :invitations, :status
  end
end
