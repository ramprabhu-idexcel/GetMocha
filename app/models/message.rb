class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	belongs_to :project
	#belongs_to :user
	 has_many :activities, :as => :resource
	has_many :users, :through=>:activities
	#has_many :activities, :dependent => :destroy
	attr_accessible :subject,:project,:user,:message,:attachments,:recipient,:project_id,:user_id

	#validates :project, :presence   => true
										
	validates :subject, :presence   => true
                    #:length     => { :within => 6..250 }
	validates :message, :presence   => true
	
	def self.send_message_to_team_members(project,message,to_users)
		team_members=project.users
		team_members.each do |team_member|
		activity=message.activities.create! :user=>team_member
			to_users.each do |to_user|
			     if to_user = team_member.email
				     activity.update_attributes(:is_subscribed=>1)
			     end	
			end
		end
	end 
	def self.send_notification_to_team_members(user,to_users)
		@user=user
		to_users.each do |to_user|
			@to_user=to_user
		ProjectMailer.delay.message_notification(@user,@to_user)
		end
	end

	
	

end



	
	



	
