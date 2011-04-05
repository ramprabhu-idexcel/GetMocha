class MessagesController < ApplicationController
	before_filter :authenticate_user!
  UPDATE_METHODS=['show','star_message','subscribe','unsubscribe','unsubscribe_via_email','destroy']
  before_filter :find_activity,:only=>['subscribe','star_message','show','unsubscribe','destroy','project_message_comment']
  before_filter :remove_timestamps,:only=>UPDATE_METHODS
  after_filter :set_timestamps,:only=>UPDATE_METHODS
	layout 'application', :except=>['new']
	before_filter :clear_session_project,:only=>['all_messages','starred_messages']
	before_filter :session_project_name,:only=>['index']
 	def index
		#~ session[:project_name]=nil
		#~ session[:project_selected]=nil
		@projects=current_user.user_active_projects
	end
	def new
		session[:attaches_id]=nil
		attachs=Attachment.recent_attachments
		attachs.each do |attach|
		Attachment.delete(attach)
		end
		if session[:project_name]
			project=Project.find(session[:project_name].id)
			@users=project.users
		else
		  @users=current_user.my_contacts
		end
		#@projects=Project.find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
	  @projects=Project.verify_project(current_user)
		@user_emails=[]
		@project_names=[]
		if @users
		  @users.each do |f|
			@user_emails<<"#{f.email}"
		  end
		end
	  #~ @projects.each do |project|
		#~ @project_names<<"#{project.name}"
	#~ end
	  render :partial=>'new',:locals=>{:user_emails=>@user_emails,:projects=>@projects}
  end
	def create
	errors=[]
		if !params[:message][:recipient].blank?
			#~ errors<<"Please enter To_email address"
		elsif !params[:message][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
			errors<<"Please enter valid email"
		end
		if !session[:project_name].nil?
		  @project=Project.find(session[:project_name].id)
		else
		  @project=Project.find(params[:project_id])
		end
	if !@project
			 render :update do |page|
			 if session[:project_name].nil?&&params[:message][:project].blank?
			 page.alert "Please Enter the Project name"
			 elsif !params[:message][:project].blank?
			 page.alert "Please enter existing projects only"
			 end
		   end
		else
			@message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@project.id)
			#~ ~ @message=Message.verify_message_parameters
			#~ @message=Message.verify_message_parameters(params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@project.id)
  		message=@message.valid?
			if @message.errors[:subject][0]=="can't be blank"
				errors<<"Please enter subject"
			elsif @message.errors[:message][0]=="can't be blank"
				errors<<"Please enter message"
			end
			if message && errors.empty?
					@message.save
					@to_users=params[:message][:recipient].split(',')
					#@project=Project.find_by_name(params[:message][:project])
					#~ Message.send_message_to_team_members(@project,@message,@to_users)
          @message.add_in_activity(@to_users)
					Message.send_notification_to_team_members(current_user,@to_users,@message)
					if !session[:attaches_id].nil?
					attachment=Attachment.recent_attachments
					attachment.each do |attach|
					attach.update_attributes(:attachable=>@message)
				  end
			end
				session[:attaches_id]=nil
				#	attachment.attachable=@message
				#attachment.save
        activity_id=current_user.activities.find_by_resource_type_and_resource_id("Message",@message.id)
				render :json=>@message.attributes.merge({:date_header=>@message.date_header,:message_date=>@message.message_date,:activity_id=>activity_id,:name=>current_user.name,:user_image=>current_user.image_url,:has_attachment=>@message.attachments.present?})
			else
				render :update do |page|
				page.alert errors.join("\n")
				end
		 end
end
	end
  def update
    activity=Activity.find_by_id(params[:id])
    message=activity.resource
    message.update_attributes(params[:message])
    render :nothing=>true
  end
  def all_messages
		#~ session[:project_name]=nil
		#~ session[:project_selected]=nil
		render :json=>current_user.all_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time,:has_attachment],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def starred_messages
		#~ session[:project_name]=nil
		#~ session[:project_selected]=nil
		render :json=>current_user.group_starred_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def project_messages
		session[:project_selected]=params[:project_id]
		render :json=>current_user.group_project_messages(params[:project_id],params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def show
    @activity.update_attribute(:is_read,true)
    msg=Message.find_by_id(@activity.resource_id)
    message=Message.find_hash(@activity.resource_id,current_user)
    message.merge!({:subscribed_user=>msg.display_subscribed_users,:is_subscribed=>current_user.is_message_subscribed?(msg.id),:all_subscribed=>msg.all_subscribed})
    comment_ids=@activity.resource.comments.collect{|x| x.id}
    activities=current_user.hash_activities_comments(comment_ids)
    render :json=>{:message=>message,:comments=>activities}.to_json
  end
  def star_message
    starred=!@activity.is_starred
    @activity.update_attribute(:is_starred,starred)
    render :json=>{:count=>current_user.starred_messages_count}
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
    if params[:activity_id]
      @activity=Activity.find_by_id(params[:activity_id])
			if @activity.resource_type=="Comment"
				valid_member=true
			else
      @project=@activity.resource.project
      valid_member=@project.is_member?(current_user.id)
		end
		
      render :text=>"The page you were looking doesn't exist" and return unless valid_member
    end
	end
  def unwanted_columns
    [:updated_at,:created_at,:is_assigned,:resource_type,:resource_id]
  end
  def resource_columns
    [:message,:project_id,:subject]
  end
  def remove_timestamps
    Activity.record_timestamps=false
  end
  def set_timestamps
    Activity.record_timestamps=true
  end
	def clear_session_project
		session[:project_name]=nil
		session[:project_selected]=nil
	end
	def session_project_name
  session[:project_name]=nil
	end	
	
end