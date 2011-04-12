class TaskListsController < ApplicationController
	layout "application", :except=>['new','settings']
	def index
		session[:project_name][]=nil
		#~ session[:project_selected]=nil
		@projects=current_user.user_active_projects
	end
	def new
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		@project_names=[]
		@projects.each do |project|
		@project_names<<"#{project.name}"
		end
		render :partial => 'new',:locals=>{:project_names=>@project_names}
	end
	def create
		errors=[]
		if !session[:project_name].nil?
		  @project=Project.find_by_name(session[:project_name])
		else
		  @project=Project.find_by_name(params[:project])
		end
			if !@project
			 render :update do |page|
			 if session[:project_name].nil?&&params[:project].blank?
			 page.alert "Please Enter the Project name"
			 elsif !params[:project].blank?
			 page.alert "Please enter existing projects only"
			 end
		 end
		 else
			 @tasklist=TaskList.new
			 @tasklist.name=params[:tlname]
		@tasklist.project_id=@project.id
		@tasklist.user_id=current_user.id
			 	tasklist=@tasklist.valid?
		if @tasklist.errors[:name][0]=="can't be blank"
			errors<<"Please enter project name"
		elsif !@tasklist.errors[:name][0].nil?
			errors<<@tasklist.errors[:name][0]
		end
	if tasklist
				@tasklist.save
				render :json=>{:name=>@tasklist.name,:project_id=>@tasklist.project_id}.to_json
				else
								render :update do |page|
				page.alert errors.join("\n")
			  end
		  end
		end
	end
  def update
    task_list=TaskList.find_by_id(params[:id])
    if task_list.name==params[:task_list][:name]
      render :nothing=>true
    else
      project=task_list.project
      other_task_list=project.task_lists.find_by_name(params[:task_list][:name])
      if other_task_list
        render :json=>{:error=>"Sorry already a task list with that name exist"}.to_json
      else
        task_list.update_attributes(params[:task_list])
        render :nothing=>true
      end
    end
  end
end
