class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
	has_many :comments, :dependent=>:destroy
	belongs_to :task_list
	belongs_to :guest
	attr_accessible :task,:name,:tasklist,:project,:notify,:due_date,:recipient,:message
end
