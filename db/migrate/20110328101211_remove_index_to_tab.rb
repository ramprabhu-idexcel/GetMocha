class RemoveIndexToTab < ActiveRecord::Migration
  def self.up
   remove_index :attachments, :attachable_id
   remove_index :attachments, :attachable_type
   remove_index :activities,:resource_id
  remove_index :activities,:resource_type
   remove_index :custom_emails,:custom_id
   remove_index :custom_emails,:custom_type
   add_index(:attachments, [:attachable_id, :attachable_type])
   add_index(:attachments, [:content_type])
   add_index(:comments, [:commentable_id, :commentable_type])
   add_index(:activities, [:resource_id, :resource_type])
   add_index(:custom_emails, [:custom_id, :custom_type])
   add_index(:tasks,[:completed_by_id])
  end
  def self.down
  end
end
