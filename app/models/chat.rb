class Chat < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
  has_many :attachments ,:as => :attachable, :dependent=>:destroy
  
  def user_name
    user.chat_name
  end
  
  def user_color
    user.color ? "##{user.color}" : "#ffffff"
  end
  def attach_urls
    images=[]
    documents=[]
    attachments.each do |attach|
      if attach.content_type && attach.content_type.include?("image")
				images<<"<a href='/file_download_from_email/#{attach.id}'><img width='75' height='75' alt='attachment' src='#{attach.public_filename(:message)}'/></a>"
      else
        documents<<"<a href='/file_download_from_email/#{attach.id}'>#{attach.filename}</a>"
      end
    end
    {:attach_image=>images,:attached_documents=>documents}
  end
end
