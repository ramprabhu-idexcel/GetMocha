require "rubygems"
require 'RMagick'
require 'aws/s3'
class Attachment < ActiveRecord::Base
  include AWS::S3
  belongs_to :attachable, :polymorphic => true
  #~ has_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
  if Rails.env.development?
    has_attachment :size => 1.megabyte..2.megabytes,:resize=>"500x500>",:thumbnails => {:big => "461x461>", :small => "21x20",:profile=>"70x70",:message=>"75x75"},:storage => :file_system, :path_prefix => 'public/attachments',  :processor => 'Rmagick'
  else
    has_attachment :size => 1.megabyte..2.megabytes,:thumbnails => {:big => "461x461>", :small => "21x20",:profile=>"69x69",:message=>"75x75"},:storage => :s3, :path_prefix => 'public/attachments',  :processor => 'Rmagick'
  end
  named_scope :recent_attachments, :conditions=>['attachable_id IS NULL AND parent_id IS NULL']
def self.delete_attachments(ids)
  ids.each do |id|
attach=find(:first,  :conditions=>['id=? AND attachable_id IS NULL AND parent_id IS NULL',id])
attach.delete if attach
end
end
def self.update_attachments(ids,attachable)
  puts ids.inspect
  ids=ids.split(',').flatten
  puts ids.inspect
  ids.each do |id|
attach=find(:first,  :conditions=>['id=? AND attachable_id IS NULL AND parent_id IS NULL',id])
attach.update_attributes(:attachable=>attachable) if attach
end
end
  #~ named_scope :recent_attachments, :conditions=>['attachable_id IS NULL']
  #~ named_scope :user_attachments, :conditions=>['attachable_id = ?',self.user.id], :limit=> 1
  #~ after_save :resize_image_for_thumbnail
  def resize_image_for_thumbnail
    #~ p self.thumbnails
    if self.content_type.split('/')[0]=="image"
      if self.thumbnail.nil?
        self.thumbnails.each do |file|
        fixed_width=200
          unless file.thumbnail=="big"
            width=file.parent.width
            height=file.parent.height
            if Rails.env.development?
              full_path = File.join(Rails.root, 'public/', file.parent.public_filename)
              save_path = File.join(Rails.root, 'public/', file.public_filename)
            else
              full_path = file.parent.public_filename
              save_path = file.public_filename
            end
            size= height<width ? height : width
            img = Magick::Image.read(full_path).first
            if fixed_width>size
              white_bg = Magick::Image.new(fixed_width, fixed_width)
              img_part=white_bg.composite(img,Magick::CenterGravity,0,0,Magick::OverCompositeOp)
            else
              logger.info(img_part)
              img_part = img.crop(Magick::CenterGravity,size,size)
            end
            img_part=img_part.resize(file.image_width,file.image_width)
            file_path="#{Rails.root}/public/#{file.public_filename}"
            img_part.write(file_path)
          end
        end
      end
    end
  end
  def create_event
    if Rails.env.development?
      img_part.write(save_path)
    else
      file_path="#{Rails.root}/public/#{file.filename}"
      img_part.write(file_path)
    end
  end
  def image_width
    case self.thumbnail
      when "small"
        75
      when "message"
        51
      when "profile"
        91
      when "big"
      461
    end
  end
  def find_thumbnail(name)
    image=Attachment.find_by_parent_id_and_thumbnail(id,name)
  end
end