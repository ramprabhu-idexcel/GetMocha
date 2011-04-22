class ProjectGuest < ActiveRecord::Base
	belongs_to :project
	belongs_to :guest,:class_name=>"User"
	belongs_to :task_list
end
