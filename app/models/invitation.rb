class Invitation < ActiveRecord::Base
  
	belongs_to :project
	attr_accessible :email, :message
	
	validates :email, :presence   => true,
										:uniqueness => true,
                    :format => { :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i },
                    :length     => { :within => 6..100 }
	validate :name, :length     => { :within => 3..40 }
end
