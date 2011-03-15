class MessagesController < ApplicationController
	#~ before_filter :authenticate_user!
	layout 'application'
	def new
		
	end
	def create
		p "---------------"
		p params.inspect
		p current_user
		@message=Message.new(params[:message])
		@message.user_id=current_user
		@message.save
		#~ @invites=Invitation.new(params[:data])
		#~ @invites.message_id=@message.id
		#~ @invites.save
		render :nothing=>true
		
	end
	
	
end
