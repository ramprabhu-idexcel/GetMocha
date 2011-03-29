class ApplicationController < ActionController::Base
skip_before_filter :verify_authenticity_token
#~ protect_from_forgery  layout :change_layout
before_filter :http_authenticate
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
      from_address=params[:from].to_s
				if(from_address.include?('<'))
					from_address=from_address.split('<')
					from_address=from_address[1].split('>')
					from_address=from_address[0]
				end
				to_address=params[:to].split(',')
				cc_address=params[:cc].split(',') if params[:cc]
				user=User.find_by_email(from_address)
				if user
					message=params[:text]
					name=params[:subject].to_s
					project=Project.create(:user_id=>user.id, :name=>name, :is_public=>true)
					to_address.each do |mail|
						mail=mail.strip
						if(mail.include?('<'))
							mail=mail.split('<')
							mail=mail[1].split('>')
							mail=mail[0]
						end
						if !mail.to_s.include?("p.getmocha.com")
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
						if !mail.to_s.include?("p.getmocha.com")
							invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
							ProjectMailer.delay.invite_people(user,invite)
						end
					end
					end
				end
      end
      def message_create_via_email
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
				proj_user=ProjectUser.find_by_project_id_and_user_id(project.id, user.id) if user
				proj_user=ProjectGuest.find_by_project_id_and_guest_id(project.id, user.id) if !proj_user && user
				logger.info user.inspect if user
				logger.info proj_user.inspect if proj_user
				message=params[:html]
				name=params[:subject].to_s
				if ((!proj_user || !user)  &&  project.is_public? )
					guest=User.create(:email=>from_address,:is_guest=>true, :password=>Encrypt.default_password)  if !user
					if user
						message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
						message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>user.id) 
					else
						message=Message.create(:user_id=>guest.id, :project_id=>project.id, :subject=>name, :message=>message)
						message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>guest.id) 
					end
					ProjectGuest.create(:guest_id=>guest.id,:project_id=>project.id) if guest
				
				elsif ((user && !user.is_guest && proj_user) || project.is_public?)
					message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
					activity=Activity.create(:user_id=>user.id, :resource_type=>"Message", :resource_id=>message.id)
				if params[:attachments] && params[:attachments].to_i > 0
					for count in 1..params[:attachments].to_i
						attach=message.attachments.create(:uploaded_data => params["attachment#{count}"])
					end
				end	
      end
			logger.info message.inspect if message
		end
		
	def reply_to_message_via_email
			from_address=params[:from].to_s
			if(from_address.include?('<'))
				from_address=from_address.split('<')
				from_address=from_address[1].split('>')
				from_address=from_address[0]
			end
			message_id=@dest_address.split('@')
			message_id=message_id[0].split('ctzm')
			message_id=message_id[1]
			message=Message.find(message_id)		
			project=Project.find(message.project_id)
			user=User.find_by_email(from_address)
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
  protected
  def http_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "getmocha" && password == "m0cha345"
    end
    warden.custom_failure! if performed?
  end
end