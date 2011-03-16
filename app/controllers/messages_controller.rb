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
	#~ render :partial=>'new'
		end
	def create
		@a=User.find_by_email(params[:message][:recipient])
		@b=Project.find_by_name(params[:message][:project])
	
    @message=Message.new(:subject=> params[:message][:subject], :message=> params[:message][:message],:user_id=> @a.id, :project_id=>@b.id)
		
		@message.save
		#~ @attach=Attachment.new(params[:data])
		#~ @attach.message_id=@message.id
		#~ @attach.save
		render :nothing=>true
		
	end
	
	
end
