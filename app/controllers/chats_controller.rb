class ChatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @projects=Project.user_active_projects(current_user.id)
  end
  def create
    send_to_clients ["message", current_user.chat_name, params[:chat][:message],params[:chat][:project_id]]
    render :nothing=>true
  end
  private
  def send_to_clients(data)	
    Socky.send(data.collect{|d| CGI.escapeHTML(d)}.to_json)
	end
end
