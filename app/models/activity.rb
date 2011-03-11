class Activity < ActiveRecord::Base
	has_many :projects, :through=>:messages
	belongs_to :resource, :polymorphic => true

	belongs_to :user
	
end
