class Message < ActiveRecord::Base
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	has_many :attachments ,:as => :attachable, :dependent=>:destroy
	belongs_to :project
	belongs_to :user
	 has_many :activities, :as => :resource, :dependent=>:destroy
	has_many :users, :through=>:activities
	#has_many :activities, :dependent => :destroy
	attr_accessible :subject,:project,:user,:message,:attachments,:recipient,:project_id,:user_id

	#validates :project, :presence   => true
										
	validates :subject, :presence   => true
                    #:length     => { :within => 6..250 }
	validates :message, :presence   => true
	
	def self.send_message_to_team_members(project,message,to_users)
			@to_users=to_users
		team_members=project.users
		team_members.each do |team_member|
			activity=message.activities.create! :user=>team_member
			activity.update_attributes(:is_subscribed=>1) if @to_users.include? team_member.email || current_user 
		end
		  @to_users.each do |to_user|
			@user=User.find_by_email(to_user)
		#	if !@user.nil?
			#to_usr=user.create! :user.email=>to_user	
			activity=message.activities.create! :user=>@user, :is_subscribed=>true
			#else !team_members.include? to_user
				#activity=Activity.new! :resource_type=>"Message", :user=>to_usr.id,:resource_id=>message.id, :is_subscribed=>true
			#end 
		end
			
			
  end 
    
	def self.send_notification_to_team_members(user,to_users)
		@user=user
		to_users.each do |to_user|
			@to_user=to_user
		ProjectMailer.delay.message_notification(@user,@to_user)
		end
	end

	def self.find_hash(id)
    message=self.find_by_id(id,:select=>[:subject,:message,:project_id,:user_id,:updated_at])
    user=message.user
    message.attributes.merge({:name=>user.name})
  end
	

end



	
	



	
