class Task < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	has_many :activities, :polymorphic => true
	has_many :comments, :through => :activities, :dependent => :destroy
	belongs_to :tasklist
	belongs_to :guest
end
