class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application', :except=>['new']
	def index
		@projects=current_user.projects(:conditions=>['status!=?', 3])
	end
	def new
		@users=User.find(:all,:select=>[:first_name,:email])
		@projects=Project.find(:all,:select=>[:name])
		@tcMovies=[]
		@Movies=[]
		@users.each do |f|
		@tcMovies<<"#{f.email}"
	end
	@projects.each do |g|
		@Movies<<"#{g.name}"
	end
	render :partial=>'new'
end


	def create
		@project=Project.find_by_name(params[:message][:project])
		@message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@project.id)
			message=@message.valid?
				errors=[]
      @message.errors.each_full{|msg| 
				errors<< msg 
			} 
		if message
		@message.save
		@to_users=params[:message][:recipient].split(', ')
		Message.send_message_to_team_members(@project,@message,@to_users)
		Message.send_notification_to_team_members(current_user,@to_users)
		render :nothing=>true
		else
					render :update do |page|
				page.alert errors.join("\n")
			end
		end
	end
	
	
end
