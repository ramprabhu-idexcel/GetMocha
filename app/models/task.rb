class Task < ActiveRecord::Base
	belongs_to :user
	has_many :activities, :as => :resource, :dependent=>:destroy
	has_many :comments, :as=>:commentable, :dependent=>:destroy
	has_many :attachments ,:as => :attachable, :dependent=>:destroy
	belongs_to :task_list
		belongs_to :project
	belongs_to :guest
	attr_accessible :name,:notify,:due_date,:recipient,:description,:project_id,:user_id,:task_list_id
                    #:length     => { :within => 6..250 }
	validates :description, :presence => true
  validates :name, :presence   => true
  validate :unique_name,:on=>:create

  def unique_name
    task_list=self.task_list
    task=task_list.tasks.find(:first,:conditions=>['tasks.name=?',self.name])
    task ? errors.add(:name,"A task with that name already exists") : true
  end
  def create_activities(assigned_email,susbscribe)
    assigned_user=User.verify_email_id(assigned_email)
    project=self.task_list.project
    assigned_email=self.user.email unless assigned_user && project.is_member?(assigned_user.id)
    susbscribe_emails=get_emails(susbscribe,assigned_email)
    assigned_email=self.user.email unless assigned_email.present?
    project.all_members.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attributes(:is_subscribed=>susbscribe_emails.include?(user.email),:is_assigned=>(assigned_email==user.email)) 
    end
     susbscribe_emails.each do |email|
      user=User.verify_email_id(email)
      user= User.create(:email=>email,:is_guest=>true, :password=>Encrypt.default_password) unless user
      activity=Activity.find_or_create_by_user_id_and_resource_type_and_resource_id(user.id,self.class.name,self.id)
      activity.update_attributes(:is_subscribed=>true)
      if !project.project_member?(user.id)
        ProjectGuest.create(:guest_id=>user.id,:project_id=>self.task_list.project_id) 
        activity.update_attributes(:is_delete=>true)
      end
      self.send_task_notification(user)
    end
    self.send_assign_notification(assigned_email)
  end
  def get_emails(emails,assigned_email)
    subscribe_emails=emails.split(',').collect{ |arr| arr.strip }
    subscribe_emails=subscribe_emails.reject{ |arr| arr.all?(&:blank?) }
    subscribe_emails<<self.user.email
    subscribe_emails<<assigned_email
    return subscribe_emails.uniq
  end
  def send_task_notification(user)
    ProjectMailer.delay.task_notification(user,self)
  end
  def send_assign_notification(email)
    user=User.verify_email_id(email)
    ProjectMailer.delay.task_assign_notification(user,self)
  end
  #~ def add_in_activity(subscribe_emails,assigned_email)
    #~ subscribe_emails=get_emails(subscribe_emails)
    #~ assigned_email=assigned_email.strip
    #~ self.task_list.project.users.each do |user|
      #~ activity=self.activities.create! :user=>user
      #~ activity.update_attributes(:is_subscribed=>true) if user.id==self.user_id || subscribe_emails.include?(user.email)
      #~ activity.update_attributes(:is_assigned=>true) if user.email==assigned_email
      #~ send_task_notification_to_team_members(self,user) if user.email==assigned_email
		#~ end
    #~ subscribe_emails.each do |email|
			#~ email=email.strip
      #~ if email.present?
        #~ u=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>email}],:include=>:secondary_emails)
        #~ u= User.create(:email=>email,:is_guest=>true, :password=>Encrypt.default_password) unless u
				#~ a=Activity.find(:first, :conditions=>['user_id=? AND resource_type=? AND resource_id=?', u.id, "Task", self.id])
        #~ if u && u.id && !self.task_list.project.is_member?(u.id)
          #~ self.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>u.id)
          #~ ProjectGuest.create(:guest_id=>u.id,:project_id=>self.task_list.project_id) 
      #~ end
    #~ end
  #~ end
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
    self.task_list.touch
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
        "Subscribed: #{subscribed_user_names[0]} and <a href='#' id='sub_other_users'>#{pluralize(subscribed_user_names.count, "other")}</a> |"
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
    get_date_value
  end
  def get_date_value
    case due_date
      when nil
        ['','']
      when Date.today
        ["Today",'present']
      when Date.yesterday
        ["Yesterday",'past']
      else
        due_date.to_date > Date.today ? [due_date.strftime("%b %e"),'future'] : [due_date.strftime("%b %e"),'past']
    end
  end
  def assigned_user
    Activity.task_activity(self.id)
  end
  def assigned_to
    activity=assigned_user
    #~ activity=Activity.assigned_project(self.id)
    fullname=activity.user if activity.present?
    activity.present? ? [fullname.full_name,activity.user_id] : ['','']
  end
  def other_task_lists
    self.task_list.project.task_lists.select([:id,:name,:project_id])
  end
  def third_pane_data
    project=self.task_list.project
    self.attributes.merge({:task_list_name=>self.task_list_name,:assigned_to=>self.assigned_to,:other_task_lists=>self.other_task_lists,:team_members=>project.members_list,:subscribe=>self.display_subscribed_users,:project_id=>self.task_list.project_id})
  end
  def subscribed_users
    activities.where('is_subscribed=? and users.status=?',true,true).includes(:user)
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
        "Subscribed: #{subscribed_user_names[0]} and <a class='expand_user' href='#'>#{pluralize(subscribed_user_names.count, "others")}</a> |"
    end
  end
  def ex_task(title,project)
    find(:first, :conditions=>['tasks.name=? AND task_lists.project_id=?',title, project.id], :include=>:task_list)
  end
  def activity_id
    activities.find_by_user_id(self.user_id).id
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
  def due_date_mail
    due_date ? "Due Date: #{due_date.strftime("%B %e, %Y")}" : nil
  end
  def mail_content(user_id)
    project=self.task_list.project
    if project.is_a_guest?(user_id) 
      ["Author: #{self.author} <br/>#{self.description} <br/>","Powered by GetMocha.com" ]
    else
      ["Project: #{project.name} <br/> #{self.task_notification}<br/>","Post new task to this project via email : #{project.task_email_id} or custom email<br/>"]
    end
  end

end
