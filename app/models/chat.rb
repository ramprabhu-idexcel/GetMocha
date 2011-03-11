class Chat < ActiveRecord::Base
	belongs_to :project
	belongs_to :user
	belongs_to :attachable, :polymorphic => true
end
