class Project < ActiveRecord::Base
	Message_email="@m.getmocha.com"
	Task_email="@t.getmocha.com"
	has_many :project_users
	has_many :project_guests
	has_many :users, :through=> :project_users
  has_many :guests,:through=>:project_guests,:source => :user
	has_many :activities, :through => :messages, :dependent=>:destroy
	has_many :messages
  has_many :tasklists
	has_many :tasks
	has_many :comments#, :through=>:activities
	has_many :custom_emails
	has_many :chats
	has_many :invitations
  belongs_to :owner,:class_name=>"User"
	attr_accessible :name,:status,:message_email_id,:task_email_id,:is_public,:user_id
	validates :name, :presence   => true
	validates :name, :length     => { :within => 3..40, :message=>"Please enter a project name with more than 3 characters and less than 20 characters" }
	after_create :create_email_ids
	
  def self.user_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND project_users.status=?',user_id,true],:include=>:project_users)
  end
	
	def self.user_active_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status!=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
	
	def self.user_completed_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
  def  create_email_ids
		self.update_attributes(:status=>ProjectStatus::ACTIVE, :message_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Message_email, :task_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Task_email)
	end
	def is_member?(user_id)
		member=Project.find(:first, :conditions=>['project_users.user_id=? AND project_users.status=?', user_id,true], :include=>:project_users)
		!member.present?
	end
	
	def has_custom_message_id?
		custom_emails.find_by_custom_type("Message").present?
	end
	
	def has_custom_task_id?
		custom_emails.find_by_custom_type("Task").present?
	end

  def project_unread_message(user_id)
    activities.find(:all,:conditions=>['activities.user_id=? AND is_read=? AND is_delete=?',user_id,false,false])
  end

  def project_unread_message_count(user_id)
    project_unread_message(user_id).count
  end
	def project_member?(user_id)
    project_guests.find_by_guest_id_and_status(user_id,true).present? || project_users.find_by_user_id_and_status(user_id,true).present?
  end
  
  def is_a_guest?(user_id)
    guest_object(user_id).present?
  end
  
  def guest_object(user_id)
    project_guests.find_by_guest_id(user_id)
  end
end
