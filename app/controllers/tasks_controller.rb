class TasksController < ApplicationController
	before_filter :authenticate_user!
#  before_filter :find_activity,:only=>['subscribe','star_task','show','unsubscribe','destroy','project_task_comment']
	layout 'application', :except=>['new']
	 before_filter :find_task,:only=>['update','complete_task','destroy','assign_task']
	 before_filter :clear_session_project,:only=>['all_tasks','starred_tasks','my_tasks','completed_tasks']
	def index
		#~ session[:project_name][]=nil
		@projects=current_user.user_active_projects
	end
  def new
		attachs=Attachment.delete_attachments(session[:attaches_id]) if !session[:attaches_id].nil?
		session[:attaches_id]=nil
    @users=current_user.my_contacts
		#~ @projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		@projects=Project.check_project_users(current_user)
		@user_emails=[]
		#~ @t_list=[]
		#~ @project_names=[]
		#~ if @users
		  @users.each do |f|
        @user_emails<<"#{f.email}"
		  end
		#~ end
	  #~ @projects.each do |project|
      #~ @project_names<<"#{project.name}"
    #~ end
	  render :partial=>'new',:locals=>{:user_emails=>@user_emails,:projects=>@projects}
	end
	def create
		errors=[]
		session[:attaches_id]=params[:attach_id]
		if !session[:project_name].nil?
		  @project=Project.find_by_id(session[:project_selected])
		else
		  @project=Project.find_by_id(params[:project_id])
		end
		if params[:task][:name].blank?
			render :update do |page|
				page.alert "Please Enter the Task name"
			end
		elsif !@project
			render :update do |page|
			  if session[:project_name].nil?&&params[:task][:project].blank?
				  page.alert "Please Enter the Project name"
			  elsif params[:project_id].blank?
			    page.alert "Please enter existing projects only"
			  end
		  end
		else
		  if params[:task][:tasklist].blank?
			  errors<< "Please Enter the tasklist name"
				
					if !params[:task][:recipient].blank?
					#~ errors<<"Please enter To_email address"
					if !params[:task][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
						errors<<"Please enter valid email for assign"
						else
							u_email=[]
							@project.users.each do |user|
								u_email<<user.email
							end
							e=u_email.indexOf(params[:task][:recipient])
							if !e
								errors<<"Please select existing user only"
							end
						end
	      end
			else
			if !params[:task][:notify].blank?
				#~ errors<<"Please enter To_email address"
				if !params[:task][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
					errors<<"Please enter valid notify email"
					end
		    end
		    @tasklist=@project.task_lists.find_by_id(params[:tasklist_id])
			  if !@tasklist
					#~ if !params[:tasklist_id].blank?
			      errors<<"Please enter existing tasklist only"
			    #~ end
		    else
					
					name=@tasklist.tasks.find_by_name(params[:task][:name])
					if name
						errors<<"Task name already exist"
						else
		      @tasks=Task.new(:name=>params[:task][:name],:description=>params[:task][:message],:user_id=>current_user.id,:due_date=>params[:due_date],:task_list_id=>@tasklist.id) if !@tasklist.nil?
			    tasks=@tasks.valid?
					if @tasks.errors[:name][1]=="can't be blank"
				    errors<<"Please enter task name"
						
					elsif !@tasks.errors[:name][0].nil?
						errors<<"Task name already exist in this task list"
		  	  elsif @tasks.errors[:description][1]=="can't be blank"
				    errors<<"Please enter description message"
					elsif !@tasks.errors[:description][0].nil?
						errors<<"Enter more than 6 charecter in task description message"
			    end
			  end
			end
		end
			if tasks && errors.empty?
		      @tasks.save
					@notify=params[:task][:notify].split(',')
					@to_user=@notify
					@to_user<<params[:task][:recipient]
					p @to_user
					#@project=Project.find_by_name(params[:message][:project])
					#~ Message.send_message_to_team_members(@project,@message,@to_users)
          @tasks.add_in_activity(@notify,params[:task][:recipient])
					Task.send_task_notification_to_team_members(current_user,@to_user,@tasks)
					if !session[:attaches_id].nil?
					  attachment=Attachment.update_attachments(session[:attaches_id],@tasks)
					 end
				  session[:attaches_id]=nil
			  	#	attachment.attachable=@message
				  #attachment.save
          activity_id=current_user.activities.find_by_resource_type_and_resource_id("Task",@tasks.id)
	        render :json=>@tasks.to_json(:only=>[:id,:name,:task_list_id],:methods=>[:task_list_name,:assigned_to,:due_date_value,:activity_id])
			  else
			    render :update do |page|
				  page.alert errors.join("\n")
				  end
	      end
	  end
  end
	def project_tasklists
		@proj=Project.find_by_id(params[:id])
		@tlist=@proj.task_lists
		 #~ if !@tlist.nil?
	#~ @tlist.each do |tl|
		 #~ @t_list<<"#{tl.name}" if !tl.name.nil?
		 #~ end
		render :json=>{:datas=>@tlist}.to_json
	#~ end
  end

  def show
    project=Project.find_by_id(params[:id])
		session[:project_name]=project.name if project
    session[:project_selected]=project.id if project
    task_ids=project.all_uncompleted_task_ids
    render :json=>current_user.group_project_tasks(task_ids).to_json(options)
  end
	def update
		t_name=@task.task_list.tasks.find_by_name(params[:task][:name])
		if t_name
			if @task.name == t_name.name
				 render :nothing=>true
			else
				render :json=>{:error=>"Task name already exist!"}.to_json
			end
		else
			@task.attributes=params[:task]
         if @task.valid?
           @task.update_attributes(params[:task])
					 render :nothing=>true
			   else
					render :json=>{:error=>@task.errors[0]}.to_json
			end
	end
  end
  def destroy
    activities=@task.activities
    activities.each do |activity|
      activity.delete
    end
    @task.delete if @task
    render :nothing=>true
  end
	def all_tasks
    render :json=>current_user.group_all_tasks.to_json(options)
  end
	def my_tasks
    render :json=>current_user.group_my_tasks.to_json(options)
  end
	def starred_tasks
    render :json=>current_user.group_starred_tasks.to_json(options)
  end
	def completed_tasks
    render :json=>current_user.group_completed_tasks.to_json(options)
  end
	def complete_task
    #~ task=Task.find_by_id(params[:id])
    @task.update_attribute(:is_completed,!@task.is_completed)
    render :json=>current_user.all_tasks_count.to_json
  end
	def project_tasks
    project=Project.find_by_id(params[:project_id])
    task_ids=project.all_uncompleted_task_ids
    render :json=>current_user.group_project_tasks(task_ids).to_json(options)
  end
  def task_comments
    activity=Activity.find_by_id(params[:activity_id])
    task=activity.resource
    comment_ids=task.comments.map(&:id)
    task_values=task.third_pane_data
    render :json=>{:task=>task_values,:comments=>current_user.hash_activities_comments(comment_ids),:attach=>task.attach_urls}.to_json
  end
  def assign_task
    assigned_user=@task.assigned_user
    assigned_user.update_attribute(:is_assigned,false) if assigned_user
    activity=Activity.find_task_activity(@task.id,params[:user_id])
    activity.update_attributes(:is_assigned=>true,:is_subscribed=>true)
    @task.subscribed_users.each do |activity|
      ProjectMailer.delay.task_reassigned(@task,activity.user)
    end
    render :nothing=>true
  end
  private
  def options
    {:except=>unwanted_columns,:include=>{:resource=>{:methods=>task_methods}}}
  end
	def unwanted_columns
    [:created_at,:updated_at,:is_read,:user_id,:is_assigned]
  end
	def task_methods
    [:task_list_name,:due_date_value,:assigned_to]
  end
	def find_task
		@task=Task.find_by_id(params[:id])
	 end	
end

