class Comment < ActiveRecord::Base
	belongs_to :commentable, :polymorphic => true
	belongs_to :user
	belongs_to :attachable, :polymorphic => true
  has_many :activities, :as => :resource, :dependent=>:destroy
  after_create :add_in_activity
  
  def add_in_activity
    self.commentable.project.users.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attribute(:is_read,true) if user.id==self.user_id
    end
  end
  
  def self.find_hash(id)
    comment=self.find_by_id(id,:select=>[:comment,:created_at,:user_id])
    user=comment.user
    date=comment.created_at 
    comment.attributes.merge({:user=>comment.user.name,:created_at=>date})
  end
end
