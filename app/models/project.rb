class Project < ActiveRecord::Base
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
end
