class ChatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @projects=Project.user_active_projects(current_user.id)
  end
  def create
    send_to_clients ["message", {:name=>current_user.chat_name,:color=>current_user.color}, params[:chat][:message],params[:chat][:project_id]]
    chat=current_user.chats.build(params[:chat])
    chat.save if chat.valid?
    render :nothing=>true
  end
  def project_chat
    @project=Project.find_by_id(params[:project_id])
    @chats=@project.chats
    render :partial=>"chat_content",:locals=>{:project=>@project}
  end
  private
  def send_to_clients(data)	
    Socky.send(data.to_json)
	end
end
