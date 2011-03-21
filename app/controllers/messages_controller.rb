class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application', :except=>['new']
	def index
		session[:project_name]=nil
		 @projects=Project.user_active_projects(current_user.id)
	end
	def new
		if session[:project_name]
			@user=current_user.project_membership
			else
		@users=current_user.my_contacts
		end
		@projects=Project.find(:all,:select=>[:name],:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
		 @user_emails=[]
		 @project_names=[]
		  @users.each do |f|
			@user_emails<<"#{f.email}"
	end
	@projects.each do |project|
		@project_names<<"#{project.name}"
	end
	render :partial=>'new'
end


	def create
		p params["undefined"].inspect
		errors=[]
		if params[:message][:recipient].blank?
			errors<<"Please enter To_email address"
				
				elsif !params[:message][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
				
			errors<<"Please enter valid email"
			
		end
		@project=Project.find_by_name(params[:message][:project])
				if !@project
						render :update do |page|
				page.alert "Please enter existing projects only"
			end
		else
		@message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@project.id)
		
			message=@message.valid?
		 	if @message.errors[:subject][0]=="can't be blank"
		 	errors<<"Please enter subject"
			elsif @message.errors[:message][0]=="can't be blank"
			errors<<"Please enter message"
			end
			
		if message
		@message.save
		@to_users=params[:message][:recipient].split(', ')
		
		@project=Project.find_by_name(params[:message][:project])
		Message.send_message_to_team_members(@project,@message,@to_users)
		Message.send_notification_to_team_members(current_user,@to_users,@message)
		attachment=Attachment.new(:uploaded_data => params["undefined"])
		attachment.attachable=@message
		attachment.save
		render :nothing=>true
		else
					render :update do |page|
				page.alert errors.join("\n")
			end
		end
	end
  end

  def all_messages
		session[:project_name]=nil
		render :json=>current_user.all_messages.to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns}})
  end
  
  def starred_messages
		session[:project_name]=nil
		render :json=>current_user.starred_messages.to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns}})
  end
  
  def project_messages
		render :json=>current_user.starred_messages.to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns}})
  end
  
  def show
    activity=Activity.find_by_id(params[:activity_id])
    message=Message.find_hash(activity.resource_id)
    comment_ids=activity.resource.comments.collect{|x| x.id}
    activities=current_user.hash_activities_comments(comment_ids)
    render :json=>{:message=>message,:comments=>activities}.to_json
  end
  
  private
  def unwanted_columns
    [:created_at,:is_assigned,:resource_type,:resource_id]
  end
  
  def resource_columns
    [:message,:project_id,:subject]
  end
end
