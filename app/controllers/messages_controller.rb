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
		@tcMovies<<"#{f.first_name}-'#{f.email}'"
	end
	@b.each do |g|
		@Movies<<"#{g.name}"
		end
		end
	def create
		@message=Message.new(params[:message])
		@message.user_id=current_user
		@message.save
		@attach=Attachment.new(params[:data])
		@attach.message_id=@message.id
		@attach.save
		render :nothing=>true
		
	end
	
	
end
