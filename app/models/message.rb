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
	
  
  def add_in_activity(to_users)
    to_users=to_users.split(',') unless to_users.is_a?(Array)
    self.project.users.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attributes(:is_read=>(user.id==self.user_id),:is_subscribed=>true) if user.id==self.user_id || to_users.include?(user.email)
    end
    to_users.each do |email|
      u=User.find_by_email(email)
      u= User.create(:email=>email,:is_guest=>true, :password=>"123456") unless u
      activity=self.activities.create(:is_subscribed=>true,:is_delete=>true,:user=>u) if self.project.is_member?(u.id)
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

	def self.find_hash(id,current_user)
    message=self.find_by_id(id,:select=>[:id,:subject,:message,:project_id,:user_id,:updated_at])
    user=message.user
    message.attributes.merge!({:name=>user.name,:updated_date=>message_created_time(message.updated_at,current_user),:attach=>message.attach_urls})
  end
  
  def self.message_created_time(time,current_user)
    user_time=current_user.user_time(time)
    diff=current_user.user_time(Time.now)-current_user.user_time(time)
		case diff
			when 0..59
				"Posted #{pluralize(diff.to_i,"second")} ago"
			when 60..3599
				"Posted #{pluralize((diff/60).to_i,"minute")} ago"  
			when 3600..86399
				"Posted #{pluralize((diff/3600).to_i,"hour")} ago" 
		else
			"Posted on #{user_time.strftime("%d/%m/%y")}"
		end
  end
        
  def self.pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
	
	def pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
  
  def subscribed_users
    activities.find(:all,:conditions=>['is_subscribed=?',true])
  end
  
  def subscribed_user_names
    subscribed_users.collect{|a| a.user.name if a.user}.sort
  end
  
  def display_subscribed_users
    case subscribed_user_names.count
      when 0
        "Subscribed: none |"
      when 1
        "Subscribed: #{subscribed_user_names[0]} |"
      when 2
        "Subscribed: #{subscribed_user_names.join(' and ')} |"
      else
        "Subscribed: #{subscribed_user_names[0]} and <a href='#'>#{pluralize(subscribed_user_names.count, "other")}</a> |"
    end
  end
  
  def all_subscribed
    "#{subscribed_user_names.join(',')} | "
  end
  
  def has_attachments
    !attachments.empty?
  end
  
  def attach_urls
    images=[]
    documents=[]
    attachments.each do |attach|
      attach.content_type && attach.content_type.include?("image") ? images<<attach.public_filename : documents<<attach.public_filename
    end
    {:attached_images=>images,:attached_documents=>documents}
  end
  
  def date_header(user=nil)
    user=self.user if user.nil?
    time=user.user_time(updated_at)
    time.strftime("%A, %B, %d, %Y")
  end
  
  def message_date(user=nil)
    user=self.user if user.nil?
    time=user.user_time(updated_at)
    time.strftime("%I:%M %P")
  end
  
end



	
	



	
