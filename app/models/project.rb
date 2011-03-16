class Project < ActiveRecord::Base
	Message_email="@m.getmocha.com"
	Task_email="@t.getmocha.com"
	has_many :project_users
	has_many :project_guests
	has_many :users, :through=> :project_users
  has_many :guests,:through=>:project_guests,:source => :user
	has_many :activities, :dependent => :destroy
	has_many :messages
  has_many :tasklists
	has_many :tasks
	has_many :comments#, :through=>:activities
	has_many :custom_emails
	has_many :chats
	has_many :invites
  belongs_to :owner,:class_name=>"User"
	attr_accessible :name,:status,:message_email_id,:task_email_id,:is_public
	validate :name, :presence   => true,
													:uniqueness => true,
													 :length     => { :within => 3..40 }
	after_create :create_email_ids
	
	def  create_email_ids
		self.update_attributes(:status=>ProjectStatus::ACTIVE, :message_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Message_email, :task_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Task_email)
	end
end
