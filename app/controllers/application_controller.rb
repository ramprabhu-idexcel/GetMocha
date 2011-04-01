class ApplicationController < ActionController::Base
skip_before_filter :verify_authenticity_token
#~ protect_from_forgery  layout :change_layout
before_filter :http_authenticate, :except=>['']
before_filter :check_from_address_email,:only=>['new_project_via_email','message_create_via_email','reply_to_message_via_email']
before_filter :find_project
layout :change_layout
  def change_layout
    if devise_controller?
      if (controller_name=="confirmations")
           %w{show}.include?(action_name) ? "before_login" : "application"
      elsif controller_name=="registrations"
         %w{edit}.include?(action_name) ? false : "before_login"
      elsif controller_name=="sessions"
         %w{edit}.include?(action_name) ? "application" : "before_login"
      else
          %w{edit}.include?(action_name) ? "before_login" : "application"
      end
    elsif controller_name=="home"
      "before_login"
    else
      "application"
    end
  end
  def find_project
    @project=Project.find_by_id(params[:project_id]) if params[:project_id]
    session[:project_name]=@project.name if @project
  end
  def new_project_via_email
		logger.info "************************"
      #~ from_address=params[:from].to_s
				#~ if(from_address.include?('<'))
					#~ from_address=from_address.split('<')
					#~ from_address=from_address[1].split('>')
					#~ from_address=from_address[0]
				#~ end
				#~ from_address=check_from_address_email(params[:from].to_s)
				logger.info @from_address
				to_address=params[:to].split(',')
				cc_address=params[:cc].split(',') if params[:cc]
				user=User.find_by_email(@from_address)
				
				if user
					message=params[:text]
					name=params[:subject].to_s
					project=Project.create(:user_id=>user.id, :name=>name, :is_public=>true)
					ProjectUser.create(:user_id => user.id, :project_id => project.id, :status => true)
					to_address.each do |mail|
						mail=mail.strip
						if(mail.include?('<'))
							mail=mail.split('<')
							mail=mail[1].split('>')
							mail=mail[0]
						end
						if !mail.to_s.include?("#{APP_CONFIG[:project_email]}")
							invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
              ProjectMailer.delay.invite_people(user,invite)
						end
					end
					
					if cc_address
					cc_address.each do |mail|
						mail=mail.strip
						if(mail.include?('<'))
							mail=mail.split('<')
							mail=mail[1].split('>')
							mail=mail[0]
						end
						if !mail.to_s.include?("#{APP_CONFIG[:project_email]}")
							invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
							ProjectMailer.delay.invite_people(user,invite)
						end
					end
					end
				end
      end
      def message_create_via_email
         #~ from_address=params[:from].to_s
				#~ if(from_address.include?('<'))
					#~ from_address=from_address.split('<')
					#~ from_address=from_address[1].split('>')
					#~ from_address=from_address[0]
				#~ end
				#~ from_address=check_from_address_email(params[:from].to_s)
        project_id=@dest_address[0].to_s
				logger.info project_id
				project_id=project_id.split('@')
				logger.info project_id
				project_id=project_id[0].split('-').last
				logger.info project_id
				project=Project.find(project_id)
				#user=User.find_by_email(from_address)
				#~ user=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>from_address}],:include=>:secondary_emails)
				user=User.verify_email_id(@from_address)
	  		proj_user=ProjectUser.find_by_project_id_and_user_id(project.id, user.id) if user
				proj_user=ProjectGuest.find_by_project_id_and_guest_id(project.id, user.id) if !proj_user && user
				
				
				message=params[:html]
				
				
				if message.include?("gmail_quote")
				message=message.split('<div class="gmail_quote">')[0]
			end
			
				
				if message.include?('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')
					message=message.split('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')[1]
  				
					message=message.split("</td></tr></table>")[0]
					
					#~ message = message[0...message.length-1].join("---")
					

				end
				
				
				if message.count("Apple-style-span") > 0 or message.count("Apple-converted-space") > 0
					message = Sanitize.clean(message, Sanitize::Config::BASIC)
				end
				
				
				if message.include?("\240")
					message=message.split("\240").join
				end
				
				if message.include?("&lt;!-- DIV {margin:0px;} --&gt;")
					message=message.split("&lt;!-- DIV {margin:0px;} --&gt;")[1]
				end
				
				name=params[:subject].to_s
				if proj_user && proj_user.status==false
					proj_user.update_attributes(:status=>true)
				end
				if ((!proj_user)  &&  project.is_public? )
					guest=User.create(:email=>from_address,:is_guest=>true, :password=>Encrypt.default_password)  if !user
					if user						
						message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
						message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>user.id)
						else
						message=Message.create(:user_id=>guest.id, :project_id=>project.id, :subject=>name, :message=>message)
						message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>guest.id)
						end
					 if guest
						 ProjectGuest.create(:guest_id=>guest.id,:project_id=>project.id)
					elsif user && user.is_guest
				  		ProjectGuest.create(:guest_id=>user.id,:project_id=>project.id)
					end
				
				elsif ((user && !user.is_guest && proj_user) || project.is_public?)
					
					message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
					#~ activity=Activity.create(:user_id=>user.id, :resource_type=>"Message", :resource_id=>message.id)
				if params[:attachments] && params[:attachments].to_i > 0
					for count in 1..params[:attachments].to_i
						attach=message.attachments.create(:uploaded_data => params["attachment#{count}"])
					end
				end	
      end
			if message && message.project
			message.project.users.each do |user|
     activity=message.activities.create! :user=>user
       activity.update_attributes(:is_read=>(user.id==message.user_id),:is_subscribed=>true) if user.id==message.user_id
		 end
		 end
			
		end
		
	def reply_to_message_via_email
			#~ from_address=params[:from].to_s
			#~ if(from_address.include?('<'))
				#~ from_address=from_address.split('<')
				#~ from_address=from_address[1].split('>')
				#~ from_address=from_address[0]
			#~ end
			#~ from_address=check_from_address_email(params[:from].to_s)
			message_id=@dest_address[0].to_s.split('@')
			message_id=message_id[0].split('ctzm')
			message_id=message_id[1]
			message=Message.find(message_id)		
			project=Project.find(message.project_id)
			user=User.find_by_email(@from_address)
			content1=params[:html].split("##Type above this line to post a reply to this message##")
			content=content1[0]
			content_f = content.split("wrote:")[0]
			content2=content_f.split("On")
			content = content2[0...content2.length-1].join("On")
			if content.include?("gmail_quote")
				content=content.split('<div class="gmail_quote">')[0]
			end
			if content.include?('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')
				content=content.split('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')[1]
				content=content.split("---")
				content = content[0...content.length-1].join("---")
			end
			if content.count("Apple-style-span") > 0 or content.count("Apple-converted-space") > 0
				 content = Sanitize.clean(content, Sanitize::Config::BASIC)
			end
			if content.include?("\240")
				content=content.split("\240").join
			end
			if user
				comment=Comment.create(:commentable_type=>"Message", :commentable_id=>message.id, :user_id=>user.id, :comment=>content)
				message.activities.each do |activity|
						activity.update_attributes(:is_read=>false)
				end
			end
			if params[:attachments] && params[:attachments].to_i > 0
				for count in 1..params[:attachments].to_i
					attach=comment.attachments.create(:uploaded_data => params["attachment#{count}"])
				end
			end
		end
			def check_from_address_email
		logger.info "************////////////////////////////////////////////************"
		@from_address=(params[:from].to_s)
		logger.info "Start"
			if(@from_address.include?('<'))
					@from_address=@from_address.split('<')
					@from_address=@from_address[1].split('>')
					@from_address=@from_address[0]
				end
				logger.info @from_address
			
		end	
  protected
  def http_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "getmocha" && password == "m0cha345"
    end
    warden.custom_failure! if performed?
  end
	

	#~ def from_email_id
	#~ @from_address=(params[:from].to_s)
  #~ end		
end