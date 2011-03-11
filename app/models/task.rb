class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :activities, :dependent => :destroy
	has_many :comments, :dependent=>:destroy
	belongs_to :tasklist
	belongs_to :guest
end
