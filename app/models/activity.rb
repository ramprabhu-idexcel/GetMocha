class Activity < ActiveRecord::Base
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
  def unread_all_message(current_user)
    find(:all,:conditions=>['resource_type=? AND is_read = ? AND is_delete=? AND user_id=?',"Message",false,false,current_user.id])
  end
  class <<self
    def user_projects_tasks(task_ids,user_id)
      find(:all,:conditions=>['resource_type=? AND is_delete=? AND resource_id IN (?) AND user_id=?',"Task",false,task_ids,user_id],:order=>"created_at desc")
    end
    def assigned_project(user_id)
      find(:first,:conditions=>['is_assigned=? AND user_id=?',true,user_id])
    end
    def check_starred_task(user_id)
      find(:all,:conditions=>['resource_type=? AND is_delete=? AND is_starred=? AND user_id=?',"Task",false,true,user_id],:order=>"created_at desc")
    end
    def check_all_unread_messages(user_id,message_ids)
      find(:all,:conditions=>['resource_type=? AND resource_id in (?) AND is_read = ? AND is_delete=? AND user_id=?',"Message",message_ids,false,false,user_id])
    end
    def check_all_tasks_info(user_id,project_ids,sort_by=nil,order=nil)
      if sort_by=="star-task"
        sort_by="is_starred"
      else
        sort_by="created_at"
      end
      order="asc" if order.nil?
      find(:all,:conditions=>['resource_type=? AND resource_id in (?) AND is_delete=? AND user_id=?',"Task",project_ids,false,user_id],:order=>"#{sort_by} #{order}")
    end
    def check_my_tasks_info(user_id,collection_ids,sort_by=nil)
      collection_ids=[collection_ids] unless collection_ids.is_a?(Array)
      if sort_by=="star-task"
        sort_by="is_starred"
      else
        sort_by="created_at"
      end
      find(:all,:conditions=>['resource_type=? AND resource_id IN (?) AND is_delete=? AND is_assigned=? AND user_id=?',"Task",collection_ids,false,true,user_id],:order=>"#{sort_by}")
    end
    def check_hash_activities_comments_info(resource_id,user_id)
      find(:all,:conditions=>['resource_type=? and resource_id in (?) and is_delete=? AND user_id=?',"Comment",resource_id,false,user_id],:select=>[:is_starred,:is_read,:resource_id,:id])
    end
    def find_activity(task_id,user_id,class_name)
      find(:first,:conditions=>['resource_type=? AND resource_id=? AND user_id=?',class_name,task_id,user_id])
    end
    def t_assigned_user
      find(:first,:conditions=>['is_assigned=?',true])
    end
    def task_activity(task_id)
      find(:first,:conditions=>['is_assigned=? AND resource_type=? AND resource_id=?',true,"Task",task_id])
    end
    def find_all_activity(collection_ids,user_id,class_name)
      collection_ids=[collection_ids] unless collection_ids.is_a?(Array)
      find(:all,:conditions=>['resource_type=? AND resource_id IN (?) AND is_delete=? AND user_id=?',class_name,collection_ids,false,user_id])
    end
  end
end
