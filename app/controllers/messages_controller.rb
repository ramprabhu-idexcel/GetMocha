class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application', :except=>['new']
	def index
		@projects=current_user.projects(:conditions=>['status!=?', 3])
	end
	def new
		@a=User.find(:all,:select=>[:first_name,:email])
		@b=Project.find(:all,:select=>[:name])
		@tcMovies=[]
		@Movies=[]
		@a.each do |f|
		@tcMovies<<"#{f.email}"
	end
	@b.each do |g|
		@Movies<<"#{g.name}"
	end
	render 'new'
		end
	def create
		@b=Project.find_by_name(params[:message][:project])
    @message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=>current_user.id, :project_id=>@b.id)
		@message.save
		@to_user=params[:message][:recipient].split(', ')
		@to_user.each do |user|
		@a=User.find_by_email(user)
		if @a 
		@activity=Activity.new(:resource_type=>"Message",:resource_id=>@message.id,:user_id=>@a.id,:is_subscribed=>true);
		@activity.save
		#~ else
			
			#~ @activity=Activity.new(:resource_type=>"Message",:resource_id=>@message.id,:user_id=>@a.id,:is_subscribed=>true);
		  #~ @activity.save
     end
		end
		#~ @attach=Attachment.new(params[:data])
		#~ @attach.message_id=@message.id
		#~ @attach.save
		render :nothing=>true
	end
	
	
end
