class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
	attr_accessible :subject,:project,:user,:message,:attachments,:recipient,:project_id,:user_id

	validates :project, :presence   => true
										
	validates :subject, :presence   => true,
                    :length     => { :within => 6..250 }
	validates :message, :presence   => true
end



	
	



	
