class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save','privacy','message_create_via_email','check_from_address_email','contact_via_email']
	before_filter :check_from_address_email,:only=>['message_create_via_email']
	protect_from_forgery  :except=>:check_email_reply_and_save
def index
	redirect_to '/messages' if current_user
end	
def check_email_reply_and_save
	  if params[:from]
      via_email_contents(params)
			render :text => "success"
	  end
	end
	
def contact_via_email
  @message=params
  ProjectMailer.delay.contact_message_send(@message)
  render :nothing=>true
end

 #~ def check_from_address_email
  #~ logger.info "********************************"
#~ logger.info params[:from].inspect
#~ logger.info "********************************"
#~ @from_address=(params[:from].to_s)

#~ if(@from_address.include?('<'))
#~ @from_address=@from_address.split('<')
#~ @from_address=@from_address[1].split('>')
#~ @from_address=@from_address[0]
#~ end
#~ logger.info @from_address.inspect
#~ logger.info "********************************"

#~ end
	
end

  	