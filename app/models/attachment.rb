require 'aws/s3'
class Attachment < ActiveRecord::Base
  include AWS::S3
  belongs_to :attachable, :polymorphic => true	
  has_attachment :size => 1.megabyte..2.megabytes,:styles => { :small => "160x160>" }
  #~ has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  has_attachment :storage => :s3, :path_prefix => 'public/attachments'
  named_scope :recent_attachments, :conditions=>['attachable_id IS NULL']
  #~ named_scope :user_attachments, :conditions=>['attachable_id = ?',self.user.id], :limit=> 1
 end
