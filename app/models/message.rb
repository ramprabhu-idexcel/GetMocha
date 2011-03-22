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
			activity=message.activities.create! :user_id=>team_member
			activity.update_attributes(:is_subscribed=>1) if @to_users.include? team_member.email || team_member==current_user 
		end
		  @to_users.each do |to_usr|
			@user=User.find_by_email(to_usr)
			if !@user
			to_usr=User.create! :email=>to_usr, :is_guest=>true, :password=>"123456"	
			activity=message.activities.create! :user=>@user, :is_subscribed=>true
			else !team_members.include? @user
			 activity=Activity.create! :resource_type=>"Message", :user_id=>@user.id,:resource_id=>message.id, :is_subscribed=>true
			end 
		end
			
			
  end 
    
	def self.send_notification_to_team_members(user,to_users,message)
		@user=user
		@message=message
		to_users.each do |to_user|
			@to_user=to_user
		ProjectMailer.delay.message_notification(@user,@to_user,@message)
		end
	end

	def self.find_hash(id)
    message=self.find_by_id(id,:select=>[:subject,:message,:project_id,:user_id,:updated_at])
    user=message.user
    message.attributes.merge({:name=>user.name})
  end
  
  def date_formats(created_at)
    diff=Time.now-time
    case diff
      when 0..59
          "#{pluralize(diff.to_i,"second")} ago"
      when 60..3599
          "#{pluralize((diff/60).to_i,"minute")} ago"  
      when 3600..86399
          "#{pluralize((diff/3600).to_i,"hour")} ago" 
      when 86400..2591999
          "#{pluralize((diff/3600).to_i,"day")} ago" 
      else
          t=(time+find_current_zone_difference(time_zone)).strftime("%l:%M %p")
    end
  end
        
  def subscribed_users
    activities.find(:all,:conditions=>['is_subscribed=?',true])
  end
  
  def subscribed_user_names
    subscribed_users.collect{|a| a.user.name}.sort
  end
  
  def display_subscribed_users
    case subscribed_user_names.count
      when 0
        "Subscribed: none"
      when 1
        "Subscribed: #{subscribed_user_names[0]} |"
      when 2
        "Subscribed: #{subscribed_user_names.join(' and ')} |"
      else
        "Subscribed: #{subscribed_user_names[0]} and <a href='#'>#{helper.pluralize(subscribed_user_names.count, "other")}</a> |"
    end
  end
  
  def all_subscribed
    "#{subscribed_user_names.join(',')} | "
  end
    
end



	
	



	
