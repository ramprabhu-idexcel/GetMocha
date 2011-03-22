class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
  before_filter :find_activity,:only=>['subscribe','star_message','show','unsubscribe','destroy']
	layout 'application', :except=>['new']
  
	def index
		session[:project_name]=nil
		 @projects=Project.user_active_projects(current_user.id)
	end
	def new
		session[:attaches_id]=nil
		if session[:project_name]
			@user=current_user.project_membership
			else
		@users=current_user.my_contacts
		end
		@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
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
		if session[:attaches_id]
			p session[:attaches_id]=session[:attaches_id].split(",")
			session[:attaches_id].each do |attach_id|
				if attach_id.present?
					attachment=Attachment.find_by_id(attach_id)
					attachment.update_attributes(:attachable=>@message)
				end
			end
		end
		session[:attaches_id]=nil
	#	attachment.attachable=@message
		#attachment.save
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
		render :json=>current_user.all_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns,:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  
  def starred_messages
		session[:project_name]=nil
		render :json=>current_user.group_starred_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns,:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  
  def project_messages
		render :json=>current_user.group_project_messages(params[:project_id]).to_json(:except=>unwanted_columns,:include=>{:resource=>{:only=>resource_columns,:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  
  def show
    @activity.update_attribute(:is_read,true)
    msg=Message.find_by_id(@activity.resource_id)
    message=Message.find_hash(@activity.resource_id)
    message.merge!({:subscribed_user=>msg.display_subscribed_users,:is_subscribed=>current_user.is_message_subscribed?(msg.id),:all_subscribed=>msg.all_subscribed})
    comment_ids=@activity.resource.comments.collect{|x| x.id}
    activities=current_user.hash_activities_comments(comment_ids)
    render :json=>{:message=>message,:comments=>activities}.to_json
  end
  
  def star_message
    starred=!@activity.is_starred
    @activity.update_attribute(:is_starred,starred)
    render :nothing=>true
  end
  
  def subscribe
    subscribed=!@activity.is_subscribed
    @activity.update_attribute(:is_subscribed,subscribed)
    render :nothing=>true
  end
	
	def unsubscribe
		@activity.update_attribute(:is_subscribed,false)
    render :nothing=>true
	end
	
	def unsubscribe_via_email
		@activity=Activity.find_by_user_id_and_resource_type_and_resource_id(params[:user_id],"Message",params[:message_id])
		@activity.update_attribute(:is_subscribed,false)
		redirect_to "/"
	end
	
  def destroy
    @activity.update_attribute(:is_delete,true)
    render :nothing=>true
  end
  
  private
  
  def find_activity
    params[:sort_by] ||="Date"
    params[:order] ||="Ascending"
    @activity=Activity.find_by_id(params[:activity_id]) if params[:activity_id]
  end
  
  def unwanted_columns
    [:created_at,:is_assigned,:resource_type,:resource_id]
  end
  
  def resource_columns
    [:message,:project_id,:subject]
  end
end
