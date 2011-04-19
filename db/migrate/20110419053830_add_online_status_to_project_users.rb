class AddOnlineStatusToProjectUsers < ActiveRecord::Migration
  def self.up
    add_column :project_users, :online_status, :boolean,:default=>false
    add_column :project_users, :last_activity, :datetime
  end

  def self.down
    remove_column :project_users, :last_activity
    remove_column :project_users, :online_status
  end
end
