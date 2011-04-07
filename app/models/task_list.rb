class TaskList < ActiveRecord::Base
	belongs_to :user
	has_many :tasks
	belongs_to :project
	validates :name, :presence   => true,
	#~ :uniqueness =>true,
	:length=>{:within=> 1...24}
end
