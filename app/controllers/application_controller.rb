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
       end  
       
       if ((controller_name=="registrations") || (controller_name=="sessions"))
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
					message=params[:html].to_s
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
              logger.info "******************************"
              logger.info invite.inspect
							ProjectMailer.invite_people(user,invite).deliver!
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
  
 
  protected

  def http_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "getmocha" && password == "m0cha345"
    end
    warden.custom_failure! if performed?
  end

  
   
  
end
