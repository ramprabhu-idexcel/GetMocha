class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
         #~ :trackable,
         
  # Setup accessible (or protected) attributes for your model
  validates :first_name,:last_name,:presence=> true
  attr_accessible :email, :password, :remember_me,:first_name,:last_name,:title,:phone,:mobile,:time_zone,:color,:status
  has_many :projects,:as=>:project_members
  #~ has_one :project
  has_many :project_users
  has_many :projects,:through=>:project_users,:as=>:project_members
  has_many :project_guests
  has_one :attachment ,:as => :attachable, :dependent=>:destroy
  has_many :chats
 # has_many :messages
  has_many :messages, :through => :activities, :source => :resource, :source_type => 'Message'
  has_many :activities
  #has_many :activities
  has_many :secondary_emails
  has_many :comments
  
  DEFAULT_AVATAR="/images/content/stuart-avatar.jpg"
  
  #starred messages from all project
  def starred_messages
    activities.find(:all,:conditions=>['resource_type=? AND is_starred=? AND is_delete=?',"Message",true,false])
  end
  
  def all_messages
    total_messages.group_by{|m| m.created_at.to_date}
  end
  
  def total_messages
    activities.find(:all,:conditions=>['resource_type=? AND is_delete=?',"Message",false])
  end
  
  def group_starred_messages
    starred_messages.group_by{|m| m.created_at.to_date}
  end
  
  def all_messages_count
    total_messages.count
  end
  
  #starred messages from the project
  def project_starred_messages(project_id)
    b=[]
    starred_messages.collect{|a| b<<a if a.resource.project_id==project_id}
    b
  end
  
  def group_project_messages(project_id)
    project_starred_messages(project_id).group_by{|m| m.created_at.to_date}
  end 
  #starred count from all project
  def starred_count
    starred_messages.count
  end
  
  #starred count of the individual project
  def project_starred_count(project_id)
    project_starred_messages(project_id).count
  end
  
  #membership in the active projects
  def active_projects
    
  end
  
  #membership in the completed projects
  def completed_projects
    
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  #overwrite method to login using the secondary emails
  def self.find_for_authentication(conditions={})
    login = conditions.delete(:email)
    find(:first,:conditions=>["users.email=:value or secondary_emails.email=:value",{:value => login}],:include=>:secondary_emails)
  end
  
  def project_memberships
    Project.user_projects(self.id)
  end
  
  
  def my_contacts
    User.find(:all,:conditions=>['project_users.project_id in (?) AND users.status=? AND project_users.status=?',project_memberships,true,true],:include=>:project_users)
  end
  
  def name
    first_name && last_name ? full_name : email
  end
  
  def activities_comments(type_ids)
    activities.find(:all,:conditions=>['resource_type=? and resource_id in (?)',"Comment",type_ids])
  end
  
  def is_message_subscribed?(message_id)
    activity=activities.find_by_resource_type_and_resource_id("Message",message_id)
    activity.is_subscribed if activity
  end
  
  def hash_activities_comments(type_ids)
    type_ids=[type_ids] unless type_ids.is_a?(Array)
    comment_activities=activities.find(:all,:conditions=>['resource_type=? and resource_id in (?)',"Comment",type_ids],:select=>[:is_starred,:is_read,:resource_id,:id])
    values=[]
    comment_activities.collect {|t| values<<Comment.find_hash(t.resource_id).merge(t.attributes)}
    values
  end
  
  def image_url
    attachment ? attachment.public_filename : DEFAULT_AVATAR
  end
  
end
