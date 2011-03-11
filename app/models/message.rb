class Message < ActiveRecord::Base
	has_many :comments
	belongs_to :project
	belongs_to :owner
	has_many :activities
	belongs_to :attachable, :polymorphic => true
end


