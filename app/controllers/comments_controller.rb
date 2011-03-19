class CommentsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create
    activity=Activity.find_by_id(params[:act])
    comment=current_user.comments.build(params[:comment])
    comment.commentable=activity.resource
    comment.save if comment.valid?
    render :json=>{:comment=>current_user.hash_activities_comments(comment.id)}.to_json
  end
end
