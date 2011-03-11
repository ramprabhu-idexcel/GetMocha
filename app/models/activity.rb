class Activity < ActiveRecord::Base

	belongs_to :resource, :polymorphic => true

	has_many :projects, :through=>:messages


	belongs_to :user
	
end
