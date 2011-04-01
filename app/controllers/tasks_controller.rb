class TasksController < ApplicationController
	before_filter :authenticate_user!
#  before_filter :find_activity,:only=>['subscribe','star_message','show','unsubscribe','destroy','project_message_comment']
	layout 'application', :except=>['new']
		def new
		session[:attaches_id]=nil
		attachs=Attachment.recent_attachments
		attachs.each do |attach|
		Attachment.delete(attach)
		end
		if session[:project_name]
			project=Project.find_by_name(session[:project_name])
			@users=project.users
		else
		  @users=current_user.my_contacts
		end
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		@user_emails=[]
		@project_names=[]
		if @users
		  @users.each do |f|
			@user_emails<<"#{f.email}"
		  end
		end
	  @projects.each do |project|
		@project_names<<"#{project.name}"
	  end
	  render :partial=>'new'
	end
	def create
		
	end
	
end
