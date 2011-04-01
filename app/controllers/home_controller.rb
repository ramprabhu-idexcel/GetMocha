class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save','privacy']
	protect_from_forgery  :except=>:check_email_reply_and_save
def index
	redirect_to '/messages' if current_user
end	
def check_email_reply_and_save
	  if params[:from]
	  @dest_address=params[:to].split(',')
	  dest_address=@dest_address[0]
			if  dest_address.include?('<')
				@dest_address=@dest_address.split('<')
				@dest_address=@dest_address[1].split('>')
				@dest_address=@dest_address[0].to_s
			end
			d=@dest_address.split('@')[0]
			logger.info d
			logger.info d=="create"
			logger.info @dest_address.class
			logger.info @dest_address[0].to_s
			logger.info @dest_address.include?("create").inspect
			if @dest_address.include?("create")
				new_project_via_email
			elsif @dest_address.include?("#{APP_CONFIG[:message_email]}")
				message_create_via_email
			elsif @dest_address.include?("ctzm")
				reply_to_message_via_email
			end
			render :text => "success"
	  end
	end
	
end

  	