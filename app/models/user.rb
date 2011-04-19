class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,:recoverable, :rememberable,  :confirmable,:validatable
  validates :first_name,:last_name,:presence=> true,:if=>:not_guest
  validates :terms_conditions,:acceptance => true,:if=>:not_guest
  validates :email,:presence => true, :uniqueness => true, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i},:if=>:not_an_secondary
  attr_accessible :email, :password, :remember_me,:first_name,:last_name,:title,:phone,:mobile,:time_zone,:color,:status,:terms_conditions,:is_guest
  has_many :project_guests,:foreign_key=>'guest_id'
  has_many :projects
  has_many :project_users
  has_one :attachment ,:as => :attachable, :dependent=>:destroy
  has_many :chats
  has_many :messages, :through => :activities, :source => :resource, :source_type => 'Message'
  has_many :activities
  has_many :secondary_emails
  has_many :comments
  has_many :task_lists
  has_many :tasks,:through=>:task_lists
  DEFAULT_AVATAR="/images/1300771661_stock_person.png"
  named_scope :all_users, :select=>'email',:order => 'id'

  def self.verify_email_id(from_address)
    find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>from_address}],:include=>:secondary_emails)
  end
  def not_guest
    self.is_guest ? false : true
  end
  def not_an_secondary
    SecondaryEmail.find_by_email(self.email).nil? ? true : errors.add(:email,"Sorry! The Email you entered is already in use.")
  end
  def confirmation_required?
    !confirmed? && !self.is_guest
  end
  #overwrite method to login using the secondary emails
  def self.find_for_authentication(conditions={})
    login = conditions.delete(:email)
    find(:first,:conditions=>["(users.email=:value  or secondary_emails.email=:value) AND users.is_guest=:fal AND users.status=:valid",{:value => login,:fal=>false,:valid=>true}],:include=>:secondary_emails)
  end
  #starred messages from all project
  def starred_message_comments(sort_by=nil,order=nil)
    sort_field=find_sort_field(sort_by)
    message=[]
    starred_comments(nil,nil).each do |act|
      puts act.resource.commentable.id.inspect
      message<<last_created_message(act.resource.commentable.id)
    end
    message.flatten.uniq
  end
  def starred_messages(sort_by=nil,order=nil)
    order="desc" unless order
    sort_field=find_sort_field(sort_by)
    activities.where('resource_type=? AND is_starred=? AND is_delete=?',"Message",true,false).order("#{sort_field} #{order}")
  end
  def starred_comments(sort_by,order)
    order="desc" unless order
    sort_field=find_sort_field(sort_by)
    activities.where('resource_type=? AND is_starred=? AND is_delete=?',"Comment",true,false).order("#{sort_field} #{order}")
  end
  def all_messages(sort_by,order)
    total_messages(sort_by,order).group_by{|m| m.updated_at.to_date}
  end
  def total_messages(sort_by=nil,order=nil)
    sort_field=find_sort_field(sort_by)
    order="desc" unless order
    if sort_field=="is_starred"
      activities.where('resource_type=? AND is_delete=? AND is_starred=?',"Message",false,true).order("created_at #{order}")
    elsif sort_field=="is_read"
      activities.where('resource_type=? AND is_read=? AND is_delete=?',"Message",false,false).order("created_at #{order}")
    else
      activities.where('resource_type=? AND is_delete=?',"Message",false).order("#{sort_field} #{order}")
    end
  end
  def last_created_message(message_id)
    activities.where('resource_type=? AND resource_id=? AND is_delete=?',"Message",message_id,false)
  end
  def find_sort_field(sort)
    sort ||="date"
    sort.downcase!
    sort_field=case sort
      when "unread"
        "is_read"
      when "starred"
        "is_starred"
      else
        "updated_at"
    end
    sort_field
  end
  def group_starred_messages(sort_by=nil,order=nil)
    (starred_messages(sort_by,order)+starred_message_comments(sort_by,order)).uniq.group_by{|m| m.updated_at.to_date}
  end
  def group_unread_messages(order=nil)
    order="desc" unless order
    activities.where('resource_type=? AND is_read=? AND is_delete=?',"Message",false,false).order("updated_at #{order}").group_by{|m| m.updated_at.to_date}
  end
  #count of all starred messages
  def starred_messages_count
    starred_messages(nil,nil).count+starred_comments(nil,nil).count
  end
  def all_messages_count
    total_messages.count
  end
  def starred_tasks
    activities.where('resource_type=? AND is_starred=? AND is_delete=?',"Task",true,false)
  end
  def total_starred_tasks
    (starred_tasks+starred_task_com).uniq
  end
  def starred_task_com
    Activity.find_all_task_activity(self.all_starred_comment_tasks,self.id)
  end
  def starred_task_count
    starred_tasks.count+starred_task_comments.count
  end
  def all_task_comments
    comments=[]
    find_all_tasks.each do |activity|
      comments<<activity.resource.comments.map(&:id)
    end
    comments.flatten!
  end
  def starred_task_comments
    activities.find(:all,:conditions=>['resource_type=? AND resource_id IN (?) AND is_starred=?',"Comment",all_task_comments,true])
  end
  def all_starred_comment_tasks
    task_ids=[]
    starred_task_comments.each do |activity|
     task_ids<< activity.resource.commentable_id
   end
   task_ids.uniq
  end
  #starred messages from the project
  def project_starred_messages(project_id,sort_by,order)
    b=[]
    project_id=project_id.to_i
    total_messages(sort_by,order).collect{|a| b<<a if a.resource.project_id==project_id}
    b
  end
  def group_project_messages(project_id,sort_by=nil,order=nil)
    project_starred_messages(project_id,sort_by,order).group_by{|m| m.updated_at.to_date}
  end
  #starred count from all project
  def starred_count
    starred_messages.count
  end
  #starred count of the individual project
  def project_starred_count(project_id)
    project_starred_messages(project_id).count
  end
  def user_active_projects
    Project.find(:all,:conditions=>['project_users.status=? AND project_users.user_id=? AND projects.status!=?',true,self.id,ProjectStatus::COMPLETED],:include=>:project_users)
  end
  def completed_projects
    Project.find(:all,:conditions=>['project_users.status=? AND project_users.user_id=? AND projects.status=?',true,self.id,ProjectStatus::COMPLETED],:include=>:project_users)
  end
  def full_name
    "#{first_name} #{last_name}"
  end
  def project_memberships
    Project.user_projects(self.id)
  end
  def message_activity(message_id)
    activities.find_by_resource_type_and_resource_id("Message",message_id)
  end
  def my_contacts
    User.find(:all,:conditions=>['project_users.project_id in (?) AND users.status=? AND project_users.status=?',project_memberships,true,true],:include=>:project_users)
  end
  def self.members_in_project(project_id)
    find(:all,:conditions=>['project_users.project_id=? AND project_users.status=?',project_id,true],:include=>:project_users)
  end
  def self.members_as_guest(project_id)
    find(:all,:conditions=>['project_guests.project_id=? AND project_guests.status=?',project_id,true],:include=>:project_guests)
  end
  def self.all_members(project_id)
    (self.members_in_project(project_id)+self.members_as_guest(project_id)).uniq
  end
  def self.online_members(project_id)
    find(:all,:conditions=>['project_users.project_id=? AND project_users.status=? AND project_users.online_status=?',project_id,true,true],:include=>:project_users)
  end
  def name
    first_name && last_name ? full_name : email
  end
  def activities_comments(type_ids)
    activities.where('resource_type=? and resource_id in (?) and is_delete=?',"Comment",type_ids,false)
  end
  def is_message_subscribed?(message_id)
    activity=message_activity(message_id)
    activity.is_subscribed if activity
  end
  def hash_activities_comments(type_ids)
    type_ids=[type_ids] unless type_ids.is_a?(Array)
    #~ comment_activities=activities.find(:all,:conditions=>['resource_type=? and resource_id in (?) and is_delete=?',"Comment",type_ids,false],:select=>[:is_starred,:is_read,:resource_id,:id])
    comment_activities=Activity.check_hash_activities_comments_info(type_ids,self.id)
    values=[]
    comment_activities.collect {|t| values<<Comment.find_hash(t.resource_id,self).merge(t.attributes)}
    values
  end
  def image_url
    attachment ? attachment.public_filename(:small) : DEFAULT_AVATAR
  end
  def user_time(time)
    if time_zone
      time_diff=time_zone.split(")")[0].split("GMT")[1].split(":")
      hour=time_diff[0].to_i.hours
      min=time_diff[1].to_i.minutes
      total_diff=hour<0 ? hour-min : hour+min
    else
      total_diff=0.seconds
    end
    time.gmtime+total_diff.seconds
  end
  def guest_message_activities
    activities.where('resource_type=?',"Message")
  end
  def guest_task_activities
    activities.where('resource_type=?',"Task")
  end
  def guest_update_message(project_id)
    project_id=project_id.to_i
    guest_message_activities.collect{|a| a.update_attribute(:is_delete,false) if a.resource.project_id==project_id}
    guest_task_activities.collect{|a| a.update_attribute(:is_delete,false) if a.resource.task_list.project_id==project_id}
    project=Project.find_by_id(project_id)
    project.messages.each do |message|
      create_old(message)
      message.comments.each do |comment|
        create_old(comment)
      end
    end
    project.tasks.each do |task|
      create_old(task)
      task.comments.each do |comment|
        create_old(comment)
      end
    end
  end
  def create_old(object)
    activity=activities.find_or_create_by_resource_type_and_resource_id(object.class.name,object.id)
    activity.update_attributes(:created_at=>object.created_at,:updated_at=>object.updated_at)
  end
  def unread_all_message
    #~ activities.find(:all,:conditions=>['resource_type=? AND is_read = ? AND is_delete=?',"Message",false,false])
    Activity.check_all_unread_messages(self.id)
  end
  def unread_all_message_count
    unread_all_message.count
  end
  def find_all_tasks(sort_by=nil,order=nil)
    Activity.check_all_tasks_info(self.id,sort_by,order)
  end
  def all_tasks(order=nil)
    #~ activities.find(:all,:conditions=>['resource_type=? AND is_delete=?',"Task",false],:order=>"created_at desc")
    not_completed_tasks(find_all_tasks(sort_by=nil,order))
  end
  def group_all_tasks(order=nil)
    all_tasks(order).group_by{|a| a.resource.task_list_id}
  end
  def find_my_tasks(sort_by,order)
    Activity.check_my_tasks_info(self.id,sort_by,order)
  end
  def my_tasks(sort_by,order)
    #~ activities.find(:all,:conditions=>['resource_type=? AND is_delete=? AND is_assigned=?',"Task",false,true],:order=>"created_at desc")
    not_completed_tasks(find_my_tasks(sort_by,order))
  end
  def group_my_tasks(sort_by=nil,order=nil)
    my_tasks(sort_by,order).group_by{|a| a.resource.task_list_id}
  end
  def find_starred_tasks
    Activity.check_starred_task(self.id)
  end
  def starred_tasks
    #~ activities.find(:all,:conditions=>['resource_type=? AND is_delete=? AND is_starred=?',"Task",false,true],:order=>"created_at desc")
    not_completed_tasks(find_starred_tasks)
  end
  def group_starred_tasks
    total_starred_tasks.group_by{|a| a.resource.task_list_id}
  end
  def completed_tasks(sort_by,order)
    activities=[]
    find_all_tasks(sort_by,order).collect{|t| activities << t if t.resource && t.resource.is_completed}
    activities
  end
  def group_completed_tasks(sort_by,order)
    completed_tasks(sort_by,order).group_by{|a| a.resource.task_list_id}
  end
  def project_tasks(task_ids)
    Activity.user_projects_tasks(task_ids,self.id)
    #~ activities.find(:all,:conditions=>['resource_type=? AND is_delete=? AND resource_id IN (?)',"Task",false,task_ids],:order=>"created_at desc")
  end
  def not_completed_tasks(collection)
    activities||=[]
    collection.collect{|t| activities << t if t.resource && !t.resource.is_completed}
    return activities
  end
  def group_project_tasks(task_ids)
    project_tasks(task_ids).group_by{|a| a.resource.task_list_id}
  end
  def self.u_count_val
    find(:all,:conditions=>['is_guest=?',false])
  end
  def self.g_count_data
    find(:all,:conditions=>['is_guest=?',true])
  end
  def self.project_team_members(project_id)
    find(:all,:conditions=>['project_users.project_id=:project_id AND project_users.status=:value AND users.status=:value',{:project_id=>project_id,:value=>true}],:include=>:project_users,:select=>[:id,:first_name,:last_name])
  end
  def all_tasks_count
    {:completed_count=>completed_tasks(nil,nil).count,:all_count=>all_tasks(nil).count,:starred_count=>starred_task_count,:my_count=>my_tasks(nil,nil).count}
  end
  def self.find_all_user_except_guest
    find(:all,:conditions=>['is_guest=?',false])
  end
  def self.find_all_user_with_guest
    find(:all,:conditions=>['is_guest=?',true])
  end
  def chat_name
    "#{first_name.capitalize} #{last_name.first.capitalize}"
  end
end