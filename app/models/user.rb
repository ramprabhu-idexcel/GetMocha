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
  has_many :chats
 # has_many :messages
  has_many :messages, :through => :activities, :source => :resource, :source_type => 'Message'
  has_many :activities
  #has_many :activities
  has_many :secondary_emails
  
  #starred messages from all project
  def starred_messages
    Activity.find(:all,:conditions=>['resource_type=? AND is_starred=? AND is_delete=?',"Message",true,false])
  end
  
  def all_messages
    Activity.find(:all,:conditions=>['resource_type=? AND is_delete=?',"Message",false]).group_by{|m| m.created_at.to_date}
  end
  
  #starred messages from the project
  def project_starred_messages(project_id)
    starred_messages.collect{|a| a.resource.project_id==project_id}
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
  
end
