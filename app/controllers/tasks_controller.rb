class TasksController < ApplicationController
	before_filter :authenticate_user!, :except=>['unsubscribe_via_email_task']
#  before_filter :find_activity,:only=>['subscribe','star_task','show','unsubscribe','destroy','project_task_comment']
	layout 'application', :except=>['new']
	 before_filter :find_task,:only=>['update','complete_task','destroy','assign_task']
	 before_filter :clear_session_project,:only=>['all_tasks','starred_tasks','my_tasks','completed_tasks']
	 		def unsubscribe_via_email_task
		@activity=Activity.find_by_user_id_and_resource_type_and_resource_id(params[:user_id],"Task",params[:message_id])
		@activity.update_attribute(:is_subscribed,false)
		redirect_to "/"
	end
	def index
		@projects=current_user.user_active_projects
	end
  def new
		attachs=Attachment.delete_attachments(session[:attaches_id]) if !session[:attaches_id].nil?
		session[:attaches_id]=nil
    @users=current_user.my_contacts
		@projects=Project.check_project_users(current_user)
		render :partial=>'new',:locals=>{:m_users=>@users,:projects=>@projects}
	end
	def create
		session[:attaches_id]=params[:attach_id]
		if params[:task][:task_list_id].blank?
			task_list=TaskList.create(:project_id=>params[:project_id], :user_id=>current_user.id, :name=>params[:tasklist])
		end
    task=current_user.tasks.build(params[:task])
		task.task_list_id=task_list.id if params[:task][:task_list_id].blank?
		if task.valid?
      task.save
			attachment=Attachment.update_attachments(session[:attaches_id],task) if !session[:attaches_id].nil?
			session[:attaches_id]=nil
      task.create_activities(params[:recipient],params[:notify])
			if !task_list
      render :json=>task.to_json(:only=>[:id,:name,:task_list_id],:methods=>[:task_list_name,:assigned_to,:due_date_value,:activity_id])
			else
				render :json=>task.to_json(:only=>[:id,:name,:task_list_id],:methods=>[:task_list_name,:assigned_to,:due_date_value,:activity_id,:project_ids])
				end
    else
      errors=[]
      task.errors.entries.each do |err|
				 errors << err[1]
			 end
		 render :update do |page|
        page.alert errors.join('\n')
      end
    end
  end
	def project_tasklists
		@proj=Project.find_by_id(params[:id])
		@tlist=@proj.task_lists
		@users=@proj.users
		render :json=>{:datas=>@tlist, :users=>@users}.to_json
  end

  def show
    project=Project.find_by_id(params[:id])
		session[:project_name]=project.name if project
    session[:project_selected]=project.id if project
    task_ids=project.all_uncompleted_task_ids
    render :json=>current_user.group_project_tasks(task_ids,params[:order]).to_json(options)
  end
	def update
		update_task_tasklist=@task.task_list
		t_name=update_task_tasklist.tasks.find_by_name(params[:task][:name])
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
					 @users=@task.subscribed_users
					 new_task_tasklist=@task.task_list
					 @project=new_task_tasklist.project
					 @users.each do |user_act|
						  ProjectMailer.delay.task_moved_other_task_list(@task,user_act) if @project.is_member?(user_act.user_id) && params[:task][:task_list_id]
		        end
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
    if(params[:sort_by] && params[:sort_by]=="star-task")
      render :json=>current_user.group_starred_tasks.to_json(options)
    else
			puts params[:order].inspect
      render :json=>current_user.group_all_tasks(params[:order]).to_json(options)
    end
  end
	def my_tasks
    render :json=>current_user.group_my_tasks(params[:sort_by],params[:order]).to_json(options)
  end
	def starred_tasks
    render :json=>current_user.group_starred_tasks(params[:order]).to_json(options)
  end
	def completed_tasks
    render :json=>current_user.group_completed_tasks(params[:sort_by],params[:order]).to_json(options)
  end
	def complete_task
    @task.update_attribute(:is_completed,!@task.is_completed)
		@users=@task.subscribed_users
		if @task.is_completed
		@users.each do |users|
		ProjectMailer.delay.task_completed(@task,users)
	end
	end
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
		is_subs=current_user.is_task_subscribed?(task.id)
					if activity.resource_type=="Comment"
				valid_member=true
			else
			check_activity_resource=activity.resource	
      @project=task.task_list.project
      valid_member=@project.is_member?(current_user.id)
		end
		 unless valid_member
      render :text=>"The page you were looking doesn't exist" 
			else
    render :json=>{:comments=>current_user.hash_activities_comments(comment_ids),:is_subscribed=>is_subs==false ? "Subscribe" : "Unsubscibe"}.merge(task.task_comment_data).to_json
		end
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

