class Invitation < ActiveRecord::Base
  belongs_to :project
	before_create :generate_invitation_code
	attr_accessible :email, :message, :name, :project_id, :invitation_code, :status
	validates :email,
                    :format => { :with => /^[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}$/i },
                    :length     => { :within => 6..100 }
	def generate_invitation_code
		self.invitation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
	end
end
