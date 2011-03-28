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
  def has_attachment
    !resource.attachments.empty?
  end
  #~ def activity_starred_messages(sort_by,order)
    #~ find(:all,:conditions=>['resource_type=? AND is_starred=? AND is_delete=?',"Message",true,false],:order=>"#{sort_field} #{order}")
  #~ end
  #~ def activity_starred_comments(sort_by,order)
    #~ find(:all,:conditions=>['resource_type=? AND is_starred=? AND is_delete=?',"Comment",true,false],:order=>"#{sort_field} #{order}")
  #~ end
  #~ def order_by_date(order)
    #~ find(:all,:conditions=>['resource_type=? AND is_delete=? AND is_starred=?',"Message",false,true],:order=>"created_at #{order}")
  #~ end
  #~ def sort_by_order(sort_by,order)
    #~ find(:all,:conditions=>['resource_type=? AND is_delete=?',"Message",false],:order=>"#{sort_field} #{order}")
  #~ end
  #~ def activity_last_created(message_id)
    #~ find(:last,:conditions=>['resource_type=? AND resource_id=? AND is_delete=?',"Message",message_id,false])
  #~ end
  #~ def activity_guest_message
    #~ find(:all,:conditions=>['resource_type=?',"Message"])
  #~ end
  def activities_comment_hash(type_ids)
    find(:all,:conditions=>['resource_type=? and resource_id in (?) and is_delete=?',"Comment",type_ids,false],:select=>[:is_starred,:is_read,:resource_id,:id])
  end
  #~ def activity_comments(type_ids)
    #~ find(:all,:conditions=>['resource_type=? and resource_id in (?) and is_delete=?',"Comment",type_ids,false])
  #~ end
end
