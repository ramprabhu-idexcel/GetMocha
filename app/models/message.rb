class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
	has_many :commentable, :polymorphic => true
	belongs_to :attachable, :polymorphic => true
end



	
	



	
