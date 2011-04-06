class ActivitiesController < ApplicationController
  before_filter :authenticate_user!
  UPDATE_METHODS=['star_message','subscribe']
  before_filter :find_activity,:only=>UPDATE_METHODS
  before_filter :remove_timestamps,:only=>UPDATE_METHODS
  after_filter :set_timestamps,:only=>UPDATE_METHODS
  def star_message
    starred=!@activity.is_starred
    @activity.update_attribute(:is_starred,starred)
    render :json=>{:count=>current_user.starred_messages_count}
  end
  def subscribe
    subscribed=!@activity.is_subscribed
    @activity.update_attribute(:is_subscribed,subscribed)
    render :nothing=>true
  end
  private
  def find_activity
    params[:sort_by] ||="Date"
    params[:order] ||="Ascending"
    @activity=Activity.find_by_id(params[:activity_id])  if params[:activity_id]
	end
  def remove_timestamps
    Activity.record_timestamps=false
  end
  def set_timestamps
    Activity.record_timestamps=true
  end
end
