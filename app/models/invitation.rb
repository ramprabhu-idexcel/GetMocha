class Invitation < ActiveRecord::Base
  
	belongs_to :project
	attr_accessible :invite, :email, :message
	
	validates :email, :presence   => true,
										:uniqueness => true,
                  #  :format     => { :with => , :message => 		},
                    :length     => { :within => 6..100 }
	validate :name, :length     => { :within => 3..40 }
end
