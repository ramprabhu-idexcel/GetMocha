class Message < ActiveRecord::Base
	has_many :comments, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	has_many :activities, :polymorphic => true
	belongs_to :attachable, :polymorphic => true
end

def unread_count
	
