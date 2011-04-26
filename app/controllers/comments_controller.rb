class CommentsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  def create
  	session[:attaches_id]=params[:attach_id]
    activity=Activity.find_by_id(params[:act])
    comment=current_user.comments.build(params[:comment])
    comment.commentable=activity.resource
    if comment.valid?
      comment.save
      attachment=Attachment.update_attachments(session[:attaches_id],comment) unless session[:attaches_id].nil?
		  attachs=Attachment.recent_attachments
      attachs.each do |attach|
        Attachment.delete(attach)
      end unless attachs.nil?
 	    session[:attaches_id]=nil
      render :json=>{:comment=>current_user.hash_activities_comments(comment.id),:attach=>!comment.attachments.blank?}.to_json
    end
  end
end