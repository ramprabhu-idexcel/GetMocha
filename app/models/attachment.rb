require 'aws/s3'
class Attachment < ActiveRecord::Base
  include AWS::S3
  belongs_to :attachable, :polymorphic => true
  has_attachment :size => 1.megabyte..2.megabytes,:styles => { :small => "160x160>" }
  #~ has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  has_attachment :storage => :s3, :path_prefix => 'public/attachments'
 named_scope :attach_ids , :conditions=>['attachable_id IS NULL']
 end
