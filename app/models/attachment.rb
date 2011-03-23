class Attachment < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true	
  has_attachment :size => 1.megabyte..2.megabytes,:styles => { :small => "160x160>" }
  #~ has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  has_attachment :storage => :file_system, :path_prefix => 'public/attachments'
 end
