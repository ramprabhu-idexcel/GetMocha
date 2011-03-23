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
  
  def self.find_hash(id,current_user)
    comment=self.find_by_id(id,:select=>[:comment,:created_at,:user_id])
    user=comment.user
    date=Comment.find_comments_time(comment.created_at,current_user)
    comment.attributes.merge({:user=>comment.user.name,:created_at=>date})
  end
  
  def self.find_comments_time(time,current_user)
		diff=current_user.user_time(Time.now)-current_user.user_time(time)
		case diff
			when 0..59
				"#{time.strftime("%l:%M%p")} (#{pluralize(diff.to_i,"second")} ago)"
			when 60..3599
				"#{time.strftime("%l:%M%p")} (#{pluralize((diff/60).to_i,"minute")} ago)"  
			when 3600..86399
				"#{time.strftime("%l:%M%p")} (#{pluralize((diff/3600).to_i,"hour")} ago)" 
      when 86400..108000
				"#{time.strftime("%b %d")} (#{pluralize((diff/3600).to_i,"day")} ago)" 
		else
			time.strftime("%d/%m/%y")
		end
	end
  
  def self.pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
end
