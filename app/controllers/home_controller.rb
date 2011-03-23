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
		 @dest_address=@dest_address[0]
     if @dest_address.include?("#{APP_CONFIG[:project_email]}")
    new_project_via_email
			elsif @dest_address.include?("#{APP_CONFIG[:message_email]}")
				 from_address=params[:from].to_s
				if(from_address.include?('<'))
					from_address=from_address.split('<')
					from_address=from_address[1].split('>')
					from_address=from_address[0]
				end
        project_id=@dest_address
				project_id=project_id.split('@')
				project_id=project_id[0].split('-').last
				project=Project.find(project_id)
				user=User.find_by_email(from_address)
				logger.info project.inspect
				logger.info user.inspect
				if ((user && !user.is_guest) || project.is_public?)
     message=params[:html]
     name=params[:subject].to_s
     message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
		 logger.info message.inspect
     activity=Activity.create(:user_id=>user.id, :resource_type=>"Message", :resource_id=>message.id)
		 logger.info activity.inspect
		 logger.info "**************************************************************"
		 logger.info params[:attachments].inspect
		 	if params[:attachments] && params[:attachments].to_i > 0
				for count in 1..params[:attachments].to_i
					attach=message.attachments.create(:uploaded_data => params["attachment#{count}"]) 
					logger.info attach.inspect
				end
			end	
      end
			elsif @dest_address.downcase.include?("ctzm")
       #~ comment_for_message_via_mail(email)
     end
    end
    
	  render :text => "success"
	end
	
end
