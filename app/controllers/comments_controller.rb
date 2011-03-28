class CommentsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token
  def create
    session[:attaches_id] ||=[]
    activity=Activity.find_by_id(params[:act])
    comment=current_user.comments.build(params[:comment])
    comment.commentable=activity.resource
    if comment.valid?
      comment.save
      if !session[:attaches_id].nil?
				attachment=Attachment.recent_attachments
				attachment.each do |attach|
					attach.update_attributes(:attachable=>comment)
				end
			end
      session[:attaches_id]=nil
		  attachs=Attachment.recent_attachments
      if !attachs.nil?
		    attachs.each do |attach|
		      Attachment.delete(attach)
        end
      end
 	    session[:attaches_id]=nil
      if comment.attachments.blank?
			render :json=>{:comment=>current_user.hash_activities_comments(comment.id),:attach=>false}.to_json
      else
        render :json=>{:comment=>current_user.hash_activities_comments(comment.id),:attach=>true}.to_json
      end
    end
  end
end