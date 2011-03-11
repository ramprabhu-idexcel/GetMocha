class Project < ActiveRecord::Base
	has_many :project_users
	has_many :project_guests
	has_many :owners, :through=> :project_users
	has_many :activities, :dependent => :destroy
	has_many :messages
	has_many :tasks
	has_many :tasklists
	has_many :comments, :through=>:activities
	has_many :custom_emails
	has_many :chats
	has_many :invites
end
