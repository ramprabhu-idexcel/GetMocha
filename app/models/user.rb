class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
         #~ :trackable,
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :projects
  has_one :project
  has_many :project_users
  has_many :guest_users
  has_many :chats
  has_many :messages
  has_many :activities
  
  #starred messages from all project
  def starred_messages
    activities.find(:all,:conditions=>['resource_type=? AND is_starred=? AND is_delete=?',"Message",true,false])
  end
  
  #starred messages from the project
  def project_starred_messages(project_id)
    all_starred_messages.collect{|a| a.resource.project_id==project_id}
  end
  
  #starred count from all project
  def starred_count
    all_starred_messages.count
  end
  
  #starred count of the individual project
  def project_starred_count(project_id)
    project_starred_messages(project_id).count
  end
  
  #membership in the active projects
  def active_projects
    
  end
  
  
end
