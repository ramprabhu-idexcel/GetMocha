class Attachment < ActiveRecord::Base
  has_attachment :size => 1.megabyte..2.megabytes
  has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  has_attachment :storage => :file_system, :path_prefix => 'public/files'
  belongs_to :attachable, :polymorphic => true	

end
