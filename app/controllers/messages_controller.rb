class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application', :except=>['new']
	def index
		 @projects=Project.user_active_projects(current_user.id)
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
		errors=[]
		if params[:message][:recipient].blank?
			errors<<"Please enter To_email address"
				
				elsif !params[:message][:recipient].match(/([a-z0-9_.-]+)@([a-z0-9-]+)\.([a-z.]+)/i)
					render :update do |page|
				page.alert "Please enter valid email"
			end
		end
		@project=Project.find_by_name(params[:message][:project])
				if !@project
						render :update do |page|
				page.alert "Please enter existing projects only"
			end
		else
		@message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@project.id)
		p"--------------"
			message=@message.valid?
				
				p @message.errors
			 	if @message.errors[:subject][0]=="can't be blank"
			  	errors<<"Please enter subject"
			  elsif @message.errors[:message][0]=="can't be blank"
					errors<<"Please enter message"
				end
			end
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
