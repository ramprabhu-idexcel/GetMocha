class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
	attr_accessible :subject,:project_id,:user_id,:message
	validates :email, :presence   => true,
										:uniqueness => true,
                    :format => { :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i },
                    :length     => { :within => 6..100 }
	validates :project, :presence   => true,
										:length     => { :within => 3..40 }
	validates :subject, :presence   => true,
                    :length     => { :within => 6..250 }
	validates :message, :presence   => true
end



	
	



	
