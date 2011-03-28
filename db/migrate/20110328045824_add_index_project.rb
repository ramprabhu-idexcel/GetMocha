class AddIndexProject < ActiveRecord::Migration
  def self.up
	     add_index(:projects, [:user_id, :message_email_id, :task_email_id ], :unique => true)
  end

  def self.down
  end
end
