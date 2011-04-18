class ChatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @projects=Project.user_active_projects(current_user.id)
  end
  def create
    send_to_clients ["message", {:name=>current_user.chat_name,:color=>current_user.color}, params[:chat][:message],params[:chat][:project_id]]
    render :nothing=>true
  end
  def show
    @project=Project.find_by_id(params[:id])
    @chats=@project.chats
  end
  private
  def send_to_clients(data)	
    Socky.send(data.to_json)
	end
end
