class Activity < ActiveRecord::Base

	#~ belongs_to :resource, :polymorphic => true

	#~ has_many :projects, :through=>:messages


	#~ belongs_to :user
	belongs_to :resource, :polymorphic => true
  belongs_to :user
  
  def created_time
    activity_created_time(created_at,user)
  end
  
  def activity_created_time(time,current_user)
    user_time=current_user.user_time(time)
    diff=current_user.user_time(Time.now.gmtime)-user_time
    (0..86399).member?(diff) ? user_time.strftime("%I:%M %p") : user_time.strftime("%d/%m/%y")
  end
end
