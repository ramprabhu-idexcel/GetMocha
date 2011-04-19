class Chat < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	belongs_to :attachable, :polymorphic => true
  
  def user_name
    user.chat_name
  end
  
  def user_color
    user.color ? "##{user.color}" : "#ffffff"
  end
end
