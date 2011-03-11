class Comment < ActiveRecord::Base
	belongs_to :commentable
	belongs_to :user
end
