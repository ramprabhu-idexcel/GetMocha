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
			if @dest_address[0].to_s.include?("#{APP_CONFIG[:project_email]}")
				new_project_via_email
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:message_email]}")
				message_create_via_email
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:task_email]}")
				task_create_via_email
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:invite_email]}")
				invite_via_email
			elsif @dest_address[0].to_s.include?("ctzm")
				reply_to_message_via_email
			elsif @dest_address[0].to_s.include?("ctzt")
				reply_to_task_via_email
			end
			render :text => "success"
	  end
	end
	
end

  	