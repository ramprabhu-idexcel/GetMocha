class Comment < ActiveRecord::Base
	belongs_to :commentable
	belongs_to :user
	belongs_to :attachable, :polymorphic => true
end
