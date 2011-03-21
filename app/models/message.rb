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
    
	def self.send_notification_to_team_members(user,to_users,message)
		@user=user
		@message=message
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
	 def date_formats(created_at)
		month=created_at.month
		day=created_at.day
		hour=created_at.hour
		min=created_at.min
		year1=Time.now.year-created_at.year
		month1=Time.now.month-created_at.month
		day1=Time.now.day-created_at.day
		hour1=Time.now.hour-created_at.hour
		min1=Time.now.min-created_at.min
	p sec1=Time.now.sec-created_at.sec
		if year1>=1&&(month1>1||day1>30)
		  p "#{year}/#{month}/#{day}"
		elsif day1>1 ||hour1>23
			p "#{month}/#{day} #{day1}day ago" if day1==1
			p "#{month}/#{day} #{day1}days ago" if day1>1
		elsif hour1>1||min1>59
			p "#{hour}/#{min} #{hour1}hour ago" if hour1==1
			p "#{hour}/#{min} #{hour1}hours ago" if hour1>1
		elsif min1>1&&sec1>59
			p "#{hour}/#{min} #{min1}minute ago" if min1==1
	  	p "#{hour}/#{min} #{min1}minutes ago "if min1>1
		elsif sec1>=0
			p "few seconds ago"
		
	end
	end
	

end



	
	



	
