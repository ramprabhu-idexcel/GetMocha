class TasksController < ApplicationController
	before_filter :authenticate_user!
#  before_filter :find_activity,:only=>['subscribe','star_task','show','unsubscribe','destroy','project_task_comment']
	layout 'application', :except=>['new']
	def index
		session[:project_name][]=nil
		#~ session[:project_selected]=nil
		@projects=current_user.user_active_projects
	end
		def new
			
		session[:attaches_id]=nil
		attachs=Attachment.recent_attachments
		attachs.each do |attach|
		Attachment.delete(attach)
		end
		#~ if session[:project_name]
			#~ project=Project.find_by_name(session[:project_name])
			#~ @users=project.users
		#~ else
		  @users=current_user.my_contacts
		#~ end
		p @user.inspect
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		p @projects
		@user_emails=[]
		@t_list=[]
		@project_names=[]
		if @users
		  @users.each do |f|
		  @user_emails<<"#{f.email}"
		  end
		end
	  @projects.each do |project|
		@project_names<<"#{project.name}"
	end
	#~ @tlist=@projects.task_lists.find(:all)
	#~ @tlist.each do |tl|
		#~ p @t_list<<"#{tl.name}"
		  #~ end
	  render :partial=>'new'
	end
	def create
		p params[:tasklist]
		@projects=Project.find_by_name(params[:task][:project])
		p @projects
		@tasklist=TaskList.find_by_name(params[:task][:tasklist])
		p @tasklist
		@tasks=Task.create!(:name=>params[:task][:name], :project_id=>@projects.id,:description=>params[:task][:message],:user_id=>current_user.id,:due_date=>params[:task][:due_date],:task_list_id=>@tasklist.id)
		
	
		
	
	render :nothing=>true
	end
	
end
