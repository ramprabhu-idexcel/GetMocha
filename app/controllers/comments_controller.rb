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
					attachment=Attachment.find(:all ,:conditions=>['attachable_id IS NULL'])
					attachment.each do |attach|
					attach.update_attributes(:attachable=>comment)
				end
			end
      session[:attaches_id]=nil
		attachs=Attachment.find(:all ,:conditions=>['attachable_id IS NULL'])
    if !attachs.nil?
		attachs.each do |attach|
		Attachment.delete(attach)
  end
  end
      
	session[:attaches_id]=nil
    render :json=>{:comment=>current_user.hash_activities_comments(comment.id)}.to_json
  end
  end
end
