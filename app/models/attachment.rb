require 'aws/s3'
class Attachment < ActiveRecord::Base
  include AWS::S3
  belongs_to :attachable, :polymorphic => true	
  has_attachment :size => 1.megabyte..2.megabytes,:styles => { :small => "160x160>" }
  #~ has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  if Rails.env.development?
    has_attachment :storage => :file_system, :path_prefix => 'public/attachments'
  else
    has_attachment :storage => :s3, :path_prefix => 'public/attachments'
  end
 end
