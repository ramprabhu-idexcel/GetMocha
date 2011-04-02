class TaskList < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :tasks
	validates :name, :presence   => true,
								:uniqueness =>true, 
								:length=>{:within=> 1...24}
end
