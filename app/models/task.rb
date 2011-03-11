class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :comments,:through=>activity
	belongs_to :tasklist
	belongs_to :guest
end
