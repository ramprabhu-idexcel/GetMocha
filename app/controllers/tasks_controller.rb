class TasksController < ApplicationController
	before_filter :authenticate_user!
#  before_filter :find_activity,:only=>['subscribe','star_task','show','unsubscribe','destroy','project_task_comment']
	layout 'application', :except=>['new']
	def index
		#~ session[:project_name][]=nil
		@projects=current_user.user_active_projects
	end
  def new
		session[:attaches_id]=nil
		attachs=Attachment.recent_attachments
		attachs.each do |attach|
      Attachment.delete(attach)
		end
    @users=current_user.my_contacts
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
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
	  render :partial=>'new'
	end
	def create
		errors=[]
		if !session[:project_name].nil?
		  @project=Project.find_by_name(session[:project_name])
		else
		  @project=Project.find_by_name(params[:task][:project])
		end
		if !@project
			render :update do |page|
			  if session[:project_name].nil?&&params[:task][:project].blank?
				  page.alert "Please Enter the Project name"
			  elsif !params[:task][:project].blank?
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
		      end
	      end
			else
			  if !params[:task][:notify].blank? 
			    #~ errors<<"Please enter To_email address"
		      if !params[:task][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
			      errors<<"Please enter valid notify email"
		      end
		    end
		    @tasklist=TaskList.find_by_name(params[:task][:tasklist])
		  	p @tasklist
			  p @project
			  if !@tasklist
			    if !params[:task][:tasklist].blank?
			      errors<<"Please enter existing tasklist only"
			    end
		    else
		      @tasks=Task.new(:name=>params[:task][:name],:description=>params[:task][:message],:user_id=>current_user.id,:due_date=>params[:task][:due_date],:task_list_id=>@tasklist.id) if !@tasklist.nil?
					p @tasks.inspect
			    tasks=@tasks.valid?
					p params[:task][:message]
					p @tasks.errors.inspect
					if @tasks.errors[:name][1]=="can't be blank"
				    errors<<"Please enter task name"
					elsif !@tasks.errors[:name][0].nil?
						errors<<"task name already exist in this task list"
		  	  elsif @tasks.errors[:description][1]=="can't be blank"
				    errors<<"Please enter description message"
					elsif !@tasks.errors[:description][0].nil?
						errors<<"Enter more than 6 charecter in task description message"
			    end
			  end
		  	if tasks
		      @tasks.save
					@notify="#{@notify},#{params[:task][:recipient]}"
					p @notify
					@notify=params[:task][:notify].split(',')
					#@project=Project.find_by_name(params[:message][:project])
					#~ Message.send_message_to_team_members(@project,@message,@to_users)
          @tasks.add_in_activity(@notify,params[:task][:recipient],current_user)
					Task.send_task_notification_to_team_members(current_user,@notify,@tasks)
					if !session[:attaches_id].nil?
					  attachment=Attachment.recent_attachments
					  attachment.each do |attach|
				  	attach.update_attributes(:attachable=>@tasks)
				    end
			    end
				  session[:attaches_id]=nil
			  	#	attachment.attachable=@message
				  #attachment.save
          activity_id=current_user.activities.find_by_resource_type_and_resource_id("Task",@tasks.id)
	        render :nothing=>true
			  else
			    render :update do |page|
				  page.alert errors.join("\n")
				  end
	      end
  	  end
	  end
  end
	def project_tasklists
		@t_list=[]
		p "___________________"
		@proj=Project.find_by_name(params[:id])
		@tlist=@proj.task_lists
		p @proj
		p @tlist
		 if !@tlist.nil?
	@tlist.each do |tl|
		 @t_list<<"#{tl.name}" if !tl.name.nil?
		 end
		render :json=>{:data=>@t_list}.to_json
	end
  end
  end

