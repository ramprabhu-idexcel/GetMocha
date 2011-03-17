class CustomEmail < ActiveRecord::Base
	belongs_to :project
	before_create :generate_verification_code
	validates :email,:uniqueness=>true
	def generate_verification_code
		self.verification_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
	end
end
