class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application'
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
		end
	def create
		@a=User.find_by_email(params[:message][:recipient])
		@b=Project.find_by_name(params[:message][:project])
	 p.current_user.id
	 p"------------------"
    @message=Message.new(:subject=> "params[:message][:subject]", :message=> "params[:message][:message]",:user_id=> current_user.id, :project_id=>@b.id)
		@message.save
		@activity=Activity.new(:resource_type=>"Message",:resource_id=>@message.id,:user_id=>@a.id,:is_subscribed=>true);
		@activity.save
		#~ @attach=Attachment.new(params[:data])
		#~ @attach.message_id=@message.id
		#~ @attach.save
		render :nothing=>true
		
	end
	
	
end
