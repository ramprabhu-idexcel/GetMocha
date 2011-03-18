class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true	
  has_attachment :size => 1.megabyte..2.megabytes
  has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  has_attachment :storage => :file_system, :path_prefix => 'public/attachments'

  belongs_to :attachable, :polymorphic => true	


end