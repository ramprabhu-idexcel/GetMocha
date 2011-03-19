class Comment < ActiveRecord::Base
	belongs_to :commentable, :polymorphic => true
	belongs_to :user
	belongs_to :attachable, :polymorphic => true
  
  def self.find_hash(id)
    comment=self.find_by_id(id,:select=>[:comment,:created_at,:user_id])
    user=comment.user
    date=comment.created_at 
    comment.attributes.merge({:user=>comment.user.name,:created_at=>date})
  end
end
