class Comment < ActiveRecord::Base
	belongs_to :commentable, :polymorphic => true
	belongs_to :user
	has_many :attachments,:as => :attachable, :dependent=>:destroy
  has_many :activities, :as => :resource, :dependent=>:destroy
  after_create :add_in_activity
  def add_in_activity
    self.commentable.project.users.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attribute(:is_read,true) if user.id==self.user_id
    end
    if self.commentable_type=="Message"
      self.commentable.subscribed_users.each do |activity|
        user=activity.user
        ProjectMailer.delay.message_reply(user,self)
      end
    end
  end
   def self.find_hash(id,current_user)
    comment=self.find_by_id(id,:select=>[:id,:comment,:created_at,:user_id])
    user=comment.user
    date=Comment.find_comments_time(comment.created_at,current_user)
    comment.attributes.merge({:user=>comment.user.name,:created_at=>date,:attach=>comment.attach_urls})
  end
  def self.find_comments_time(time,current_user)
    user_time=current_user.user_time(time)
		diff=current_user.user_time(Time.now)-user_time
		case diff
      when 0..59
       "#{user_time.strftime("%l:%M%p")}(#{pluralize(diff.to_i,"second")} ago)"
      when 60..3599
       "#{user_time.strftime("%l:%M%p")}(#{pluralize((diff/60).to_i,"minute")}ago)"
      when 3600..86399
       "#{user_time.strftime("%l:%M%p")}(#{pluralize((diff/3600).to_i,"hour")} ago)"
      when 86400..108000
       "#{user_time.strftime("%b %d")}(#{pluralize((diff/3600).to_i,"day")} ago)"
      else
        user_time.strftime("%d/%m/%y")
      end
	end
  def self.pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
  def attach_urls
    a=[]
    attachments.each do |attach|
      a<<attach.public_filename if attach.content_type.include?("image")
    end
    {:attach_image=>a}
  end
end