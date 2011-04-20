class ChatsController < ApplicationController
  SUBSCRIBE_ACTIONS=['subscribe','unsubscribe']
  skip_before_filter :http_authenticate,:only=>SUBSCRIBE_ACTIONS
  before_filter :authenticate_user!,:except=>SUBSCRIBE_ACTIONS
  before_filter :update_online_status,:only=>['project_chat','create','popout_chat']
  def index
    @projects=Project.user_active_projects(current_user.id)
    @user_emails=new
  end
  def new

  end
  def create
    chat=current_user.chats.build(params[:chat])
    if chat.valid?
      chat.save
			attachment=Attachment.update_attachments(session[:attaches_id],chat) if !session[:attaches_id].nil?
      session[:attaches_id]=nil
      send_to_clients ["chat", user_chat_data, chat.message,chat.project_id,chat.attach_urls,chat.id]
    end
    send_count_to_clients ["count", params[:chat][:project_id],1]
    render :nothing=>true
  end
  def invite_chat_settings
		@project=Project.find(params[:project_id])
		@email=params[:email]
    @message=params[:message]
			ProjectMailer.delay.chat_invite(current_user,@project,@email,@message)
			render :nothing=>true
      end
  def project_chat
    update_offline(params[:old],current_user.id) if params[:old].present?
    send_online_users ["online_users", user_data(current_user).merge({:project_id=>params[:project_id]})]
    send_online_users ["offline_users", {:id=>current_user.id,:project_id=>params[:old]}] if params[:old].present?
        users=User.members_in_project(params[:project_id])
	  @user_emails=[]
	  users.each do |f|
			@user_emails<<"#{f.email}"
      end
    render :partial=>"chat_content",:locals=>{:project=>@project}
  end
  def popout_chat
    send_online_users ["online_users", user_data(current_user).merge({:project_id=>params[:project_id]})]
    render :layout=>false
  end
  def load_more
    @chats=@project.next_chats(params[:page].to_i)
    render :partial=>"chat_messages",:locals=>{:chats=>@chats}
  end
  def subscribe
    #~ update_online(params["channels"]["0"],params["client_id"])
    #~ send_to_clients ["online_users",user_chat_data, params[:chat][:message],params[:chat][:project_id]]
    render :text=>"ok"
  end
  def unsubscribe
    user=User.find_by_id params["client_id"] if params["client_id"]
    if user
      send_online_users ["offline_users", {:id=>user.id,:project_id=>params["channels"]["0"]}]
      update_offline(params["channels"]["0"],params["client_id"])
    end
    render :text=>"ok"
  end
  private
  def send_to_clients(data)	
    Socky.send(data.to_json,:to=>{:channels=>params[:chat][:project_id]})
	end
  def send_online_users(data)
    Socky.send(data.to_json,:to=>{:channels=>params[:project_id]})
  end
  def send_user_offline(data)
    Socky.send(data.to_json,:to=>{:channels=>params[:project_id]})
  end
  def send_count_to_clients(data)
    Socky.send(data.to_json,:to=>{:channels=>"count"})
  end
  def update_online_status
    project_id=params[:chat][:project_id] if params[:chat]
    project_id=params[:project_id] if params[:project_id]
    update_online(project_id,current_user.id)
  end
  def update_online(project_id,user_id)
    if project_id && user_id
      project_user=ProjectUser.find_by_project_id_and_user_id(project_id,user_id)
      project_user.update_attributes(:online_status=>true,:last_activity=>Time.now) if project_user
    end
  end
  def update_offline(project_id,user_id)
     if project_id && user_id
      project_user=ProjectUser.find_by_project_id_and_user_id(project_id,user_id)
      project_user.update_attributes(:online_status=>false) if project_user
    end
  end    
  def user_data(user)
    {:name=>user.chat_name,:title=>user.title,:email=>user.email,:id=>user.id,:image=>user.image_url}
  end
  def user_chat_data
    {:name=>current_user.chat_name,:color=>current_user.color,:id=>current_user.id}
  end
  
end
