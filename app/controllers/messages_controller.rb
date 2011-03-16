class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application'
	def new
		
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
