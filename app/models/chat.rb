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
end
