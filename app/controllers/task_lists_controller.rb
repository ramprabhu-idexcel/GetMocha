class TaskListsController < ApplicationController
	layout "application", :except=>['new','settings']
	def new
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		@project_names=[]
		@projects.each do |project|
		@project_names<<"#{project.name}"
		end
		render :partial => 'new'
	end
	def create
		p params.inspect
				#~ if !session[:project_name].nil?
		  #~ @project=Project.find_by_name(session[:project_name])
		#~ else
		  #~ @project=Project.find_by_name(params[:tasklists][:project])
		#~ end
		#~ if !@project
			 #~ render :update do |page|
			 #~ if session[:project_name].nil?&&params[:tasklists][:project].blank?
			 #~ page.alert "Please Enter the Project name"
			 #~ elsif !params[:tasklists][:project].blank?
			 #~ page.alert "Please enter existing projects only"
			 #~ end
		 #~ end
		 #~ else
			 #~ @tasklist=TaskList.new(params[:tasklists])
		#~ @tasklist.project_id=@project.id
		#~ @tasklist.user_id=current_user.id
			 	#~ tasklist=@tasklist.valid?
		#~ errors=[]
		#~ if @tasklist.errors[:name][0]=="can't be blank"
			#~ errors<<"Please enter project name"
		#~ elsif !@tasklist.errors[:name][0].nil?
			#~ errors<<@tasklist.errors[:name][0]
		#~ end
	#~ end
	#~ if tasklist
				#~ @tasklist.save
				#~ else
								#~ render :update do |page|
				#~ page.alert errors.join("\n")
			#~ end
#~ end
	end
end
