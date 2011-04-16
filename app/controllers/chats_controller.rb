class ChatsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @projects=Project.user_active_projects(current_user.id)
    @user_emails=new
  end
  def new
    @users=User.all_users
	  @user_emails=[]
	  @users.each do |f|
			@user_emails<<"#{f.email}"
      end
		end
	  def create
    send_to_clients ["message", current_user.full_name, params[:chat][:message]]
    render :nothing=>true
  end
  private
  def send_to_clients(data)	
    Socky.send(data.collect{|d| CGI.escapeHTML(d)}.to_json,:to=>{:channels=>1})
	end
end
