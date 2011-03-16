class SecondaryEmail < ActiveRecord::Base
	validates :email,:uniqueness=>true,:presence=>true,:format=>{:with=>/\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i,:message=>"is not valid"}
  
  belongs_to :user
  
end
