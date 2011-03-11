class Project < ActiveRecord::Base
	has_many :project_users
	has_many :project_guests
	has_many :users, :through=> :project_users
	has_many :activities, :polymorphic => true
	has_many :messages, :through=>:activities
	has_many :tasks, :through=>:activities
	has_many :tasklists
	has_many :comments, :through=>:activities
	has_many :custom_emails
	has_many :chats
	has_many :invites
end
