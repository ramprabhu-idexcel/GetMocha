class ActivitiesController < ApplicationController
  before_filter :authenticate_user!,:except=>[:unsubscribe]
  UPDATE_METHODS=['star_message','subscribe']
  before_filter :find_activity,:only=>UPDATE_METHODS
  before_filter :remove_timestamps,:only=>UPDATE_METHODS
  after_filter :set_timestamps,:only=>UPDATE_METHODS
  def star_message
    starred=!@activity.is_starred
    @activity.update_attribute(:is_starred,starred)
    if params[:task]
      render :json=>{:count=>current_user.starred_task_count}
    else
      render :json=>{:count=>current_user.starred_messages_count}
    end
  end
  def subscribe
    subscribed=!@activity.is_subscribed
    @activity.update_attribute(:is_subscribed,subscribed)
    p @activity
    if @activity.resource_type=="Task"
      task=@activity.resource
      task_values=task.third_pane_data
      render :json=>{:task=>task_values,:subscribe=>subscribed==false ? "Subscribe" : "Unsubscribe"}
    else
      task=@activity.resource
      task_values=task.display_subscribed_users
      is_subs=current_user.is_message_subscribed?(task.id)
      all_subs=task.all_subscribed
      render :json=>{:task=>task_values,:is_subscribed=>is_subs,:all_subscribed=>all_subs}
      #~ render :nothing
    end
  end

  def unsubscribe

    activity=Activity.find_by_user_id_and_resource_type_and_resource_id(params[:user_id],"Task",params[:task_id])
    
    render :nothing=>true
    
  end
  private
  def find_activity
    params[:sort_by] ||="Date"
    params[:order] ||="Ascending"
    @activity=Activity.find_by_id(params[:activity_id])  if params[:activity_id]
	end
end
