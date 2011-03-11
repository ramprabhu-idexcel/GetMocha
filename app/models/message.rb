class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
end



	
	



	
