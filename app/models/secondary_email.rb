class SecondaryEmail < ActiveRecord::Base
	validates :email,:uniqueness=>true,:message=>"Already in use"
  
  belongs_to :user
  
end
