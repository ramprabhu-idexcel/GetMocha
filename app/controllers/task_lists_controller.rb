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
		render :partial => 'new'
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
				render :nothing=>true
				else
								render :update do |page|
				page.alert errors.join("\n")
			  end
		  end
		end
	end
end
