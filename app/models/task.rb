class Task < ActiveRecord::Base
	belongs_to :user
	has_many :activities, :as => :resource, :dependent=>:destroy
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	has_many :attachments ,:as => :attachable, :dependent=>:destroy
	belongs_to :task_list,:touch => true 
		belongs_to :project
	belongs_to :guest
	attr_accessible :name,:notify,:due_date,:recipient,:description,:project_id,:user_id,:task_list_id
                    #:length     => { :within => 6..250 }
	validates :description , :length => { :within => 6..250 },
									:presence => true
validates :name, :presence   => true
  after_create :update_task_list
def add_in_activity(to_users,assign,user)
	    to_users=to_users.split(',') unless to_users.is_a?(Array)
			assign=assign.split(',')
     # self.project.users.each do |user|
		# assign=
    self.task_list.project.users.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attributes(:is_assigned=>(user.id==self.user_id),:is_subscribed=>true) if user.id==self.user_id || to_users.include?(user.email)
    end
    to_users.each do |email|
			email=email.lstrip
      if email.nil?
        u=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>email}],:include=>:secondary_emails)
        u= User.create(:email=>email,:is_guest=>true, :password=>Encrypt.default_password) unless u
        self.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>u.id) if self.project.is_member?(u.id) && u && u.id
				activity.update_attributes(:is_assigned=>true) if user.email==assign
        ProjectGuest.create(:guest_id=>u.id,:project_id=>self.project_id) if u && u.id && !self.project.project_member?(u.id)
      end
    end
  end
	def self.task_due_time(time,current_user)
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
	
	def self.send_task_notification_to_team_members(user,to_users,task)
		@user=user
		@task=task
		to_users.each do |to_user|
			@to_user=to_user
		ProjectMailer.delay.task_notification(@user,@to_user,@task)
		end
	end
  def update_task_list
    self.task_list.update_attribute(:updated_at,Time.now)
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
	 def has_attachments
    !attachments.empty?
  end
  def attach_urls
    images=[]
    documents=[]
    attachments.each do |attach|
      if attach.content_type && attach.content_type.include?("image")
				images<<"<a href='/file_download_from_email/#{attach.id}'><img width='75' height='75' alt='attachment' src='#{attach.public_filename(:message)}'/></a>"
      else
        documents<<"<a href='/file_download_from_email/#{attach.id}'>#{attach.filename}</a>"
      end
    end
    {:attach_image=>images,:attached_documents=>documents}
  end
	def author
	"#{self.user.name} at  #{self.created_at.strftime('%I:%M %p')} on #{self.created_at.strftime('%B %d, %Y') }"
  end
  def task_notification
    "Subject: #{self.name} <br/> Author: #{self.author} <br/> Task: #{self.description}"
  end
  def comment_notify
		"Author: #{self.author} <br/> Comment: #{self.comment}"
	end
  def task_list_name
    self.task_list.name
  end
  def project
    self.task_list.project
  end
  def due_date_value
    due_date.present? ? get_date_value : ""
  end
  def get_date_value
    case due_date
      when Date.today
        "Today"
      when Date.yesterday
        "Yesterday"
      else
        due_date.strftime("%b %e")
    end
  end
  def assigned_user
    activities.find(:first,:conditions=>['is_assigned=?',true])
  end
  def assigned_to
    activity=assigned_user
    #~ activity=Activity.assigned_project(self.id)
    activity.present? ? [activity.user.full_name,activity.user_id] : ['','']
  end
  def other_task_lists
    self.task_list.project.task_lists.select([:id,:name,:project_id])
  end
  def third_pane_data
    project=self.task_list.project
    self.attributes.merge({:task_list_name=>self.task_list_name,:assigned_to=>self.assigned_to,:other_task_lists=>self.other_task_lists,:team_members=>project.members_list,:subscribe=>self.display_subscribed_users,:project_id=>self.task_list.project_id})
  end
  def subscribed_users
    activities.where('is_subscribed=?',true)
  end
  def subscribed_user_names
    subscribed_users.collect{|a| a.user.name if a.user}.sort
  end
  def all_subscribed
    "#{subscribed_user_names.join(',')} | "
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
        "Subscribed: #{subscribed_user_names[0]} and <a class='expand_user' href='#'>#{pluralize(subscribed_user_names.count, "other")}</a> |"
    end
  end
end
