class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :comments, :through => :activities
	belongs_to :tasklist
	belongs_to :guest
end
