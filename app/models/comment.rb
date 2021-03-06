class Comment < ActiveRecord::Base
	belongs_to :commentable, :polymorphic => true
	belongs_to :user
	has_many :attachments,:as => :attachable, :dependent=>:destroy
  has_many :activities, :as => :resource, :dependent=>:destroy
  after_create :add_in_activity
  def add_in_activity
    project=self.commentable.project
    project=self.commentable.task_list.project if self.commentable_type=="Task"
    project.users.each do |user|
      activity=self.activities.create! :user=>user
      activity.update_attribute(:is_read,true) if user.id==self.user_id
    end
    if self.commentable_type=="Message"
      self.commentable.subscribed_users.each do |activity|
        user=activity.user
        ProjectMailer.delay.message_reply(user,self) unless user==self.user
      end
    elsif  self.commentable_type=="Task"
      self.commentable.subscribed_users.each do |activity|
        user=activity.user
        ProjectMailer.delay.task_reply(user,self) unless user==self.user
      end
    end
  end
   def self.find_hash(id,current_user)
    comment=self.find_by_id(id,:select=>[:id,:comment,:created_at,:user_id])
    user=comment.user
    date=Comment.find_comments_time(comment.created_at,current_user)
      comment.attributes.merge({:user=>user.name,"created_at"=>date,:attach=>comment.attach_urls})
  end
  def self.find_comments_time(time,current_user)
    user_time=current_user.user_time(time)
		diff=current_user.user_time(Time.now)-user_time
		case diff
      when 0..59
       "#{user_time.strftime("%l:%M%p")} (#{pluralize(diff.to_i,"second")} ago)"
      when 60..3599
       "#{user_time.strftime("%l:%M%p")} (#{pluralize((diff/60).to_i,"minute")} ago)"
      when 3600..86399
       "#{user_time.strftime("%l:%M%p")} (#{pluralize((diff/3600).to_i,"hour")} ago)"
      when 86400..1296000
       "#{user_time.strftime("%b %d")} (#{pluralize((diff/86400).to_i,"day")} ago)"
      else
        user_time.strftime("%d/%m/%y")
      end
	end
  def self.pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end
  def attach_urls
    images=[]
    documents=[]
    attachments.each do |attach|
      if attach.content_type && attach.content_type.include?("image")
        images<<"<a href='/file_download_from_email/#{attach.id}'><img width='75' height='75' alt='attachment' src='#{attach.public_filename(:profile)}'/></a>"
      else
        documents<<"<a href='/file_download_from_email/#{attach.id}'>#{attach.filename}</a>"
      end
    end
    {:attach_image=>images,:attached_documents=>documents}
  end
  def author
    "#{self.user.name} at  #{self.created_at.strftime('%l:%M %p')} on #{self.created_at.strftime('%B %d, %Y') }"
  end
  def task_comment_notify
    "Author: #{self.author} <br/><br/> #{self.comment}"
  end
  def comment_notify
		"Author: #{self.author} <br/><br/> #{self.comment}"
	end
  def comment_data
    {:comment=>self.user.hash_activities_comments(self.id),:attach=>!self.attachments.blank? }
  end
end
