class MessagesController < ApplicationController
	before_filter :authenticate_user!, :except=>['unsubscribe_via_email']
  UPDATE_METHODS=['show','star_message','subscribe','unsubscribe','unsubscribe_via_email','destroy']
  before_filter :find_activity,:only=>['subscribe','star_message','show','unsubscribe','destroy','project_message_comment']
  before_filter :remove_timestamps,:only=>UPDATE_METHODS
  after_filter :set_timestamps,:only=>UPDATE_METHODS
	layout 'application', :except=>['new']
	before_filter :clear_session_project,:only=>['all_messages','starred_messages']
	before_filter :session_project_name,:only=>['index']
 	def index
		@projects=current_user.user_active_projects
	end
	def new
		Attachment.delete_attachments(session[:attaches_id]) if !session[:attaches_id].nil?
		session[:attaches_id]=nil
		if session[:project_name]
			project=Project.find(session[:project_selected])
			@users=project.users
		else
		  @users=current_user.my_contacts
		end
		  @projects=current_user.user_active_projects
		render :partial=>'new',:locals=>{:users=>@users,:projects=>@projects}
  end
	def create
	errors=[]
	session[:attaches_id]=params[:attach_id]
		if !params[:message][:recipient].blank?
			if !params[:message][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
			errors<<"Please enter valid email"
		end
		end
		if !session[:project_name].nil?
		  @project=Project.find_by_id(session[:project_selected])
		else
		  @project=Project.find_by_id(params[:project_id])
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
			message=@message.valid?
			if @message.errors[:subject][0]=="can't be blank"
				errors<<"Please enter subject"
			elsif @message.errors[:message][0]=="can't be blank"
				errors<<"Please enter message"
			end
			if message && errors.empty?
					@message.save
					@to_users=params[:message][:recipient].split(',')
					@message.add_in_activity(@to_users)
					Message.send_notification_to_team_members(current_user,@to_users,@message)
					if !session[:attaches_id].nil?
					attachment=Attachment.update_attachments(session[:attaches_id],@message)
				 end
				session[:attaches_id]=nil
				activity_id=current_user.activities.find_by_resource_type_and_resource_id("Message",@message.id).id
        message_value=@message.attributes.merge({:date_header=>@message.date_header,:message_date=>@message.message_date,:activity_id=>activity_id,:name=>current_user.name,:user_image=>current_user.image_url,:has_attachment=>@message.attachments.present?})
        client_ids=@message.project.team_members.map(&:id).collect{|i| "message#{i}"}
        send_message_to_clients(['message',message_value],client_ids)
				render :json=>message_value
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
		render :json=>current_user.all_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time,:has_attachment],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def starred_messages
		render :json=>current_user.group_starred_messages(params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time, :has_attachment],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def project_messages
		session[:project_selected]=params[:project_id]
		render :json=>current_user.group_project_messages(params[:project_id],params[:sort_by],params[:order]).to_json(:except=>unwanted_columns,:methods=>[:created_time, :has_attachment],:include=>{:resource=>{:only=>resource_columns,:methods=>[:message_trucate],:include=>{:user=>{:methods=>[:name,:image_url]}}}})
  end
  def show
    @activity.update_attribute(:is_read,true)
    msg=Message.find_by_id(@activity.resource_id)
    message=Message.find_hash(@activity.resource_id,current_user)
    message.merge!({:subscribed_user=>msg.display_subscribed_users,:is_subscribed=>current_user.is_message_subscribed?(msg.id),:all_subscribed=>msg.all_subscribed})
		info_activity_resource=@activity.resource
    comment_ids=info_activity_resource.comments.collect{|x| x.id}
    activities=current_user.hash_activities_comments(comment_ids)
    render :json=>{:message=>message,:comments=>activities}.to_json
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
			check_activity_resource=@activity.resource	
      @project=check_activity_resource.project
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
	def session_project_name
  session[:project_name]=nil
  end	
	def send_message_to_clients(data,client_ids)
    Socky.send(data.to_json,:to=>{:channels=>client_ids})
  end
end