require 'digest/sha1'
class SecondaryEmail < ActiveRecord::Base
	validates :email,:uniqueness=>true,:presence=>true,:format=>{:with=>/\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i,:message=>"is not valid"}
  belongs_to :user
  after_create :send_verification
  def send_verification
    code=Encrypt.verification_code
    self.update_attribute(:confirmation_token,code)
    UserMailer.delay.verify_secondary_email(self.email,code)
  end
 end
