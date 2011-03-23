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
       #~ new_message_create_via_mail
			elsif @dest_address.downcase.include?("ctzm")
       #~ comment_for_message_via_mail(email)
     end
    end
    
	  render :text => "success"
	end
	
	  def new_post_create_via_mail
    from_address=params[:from].to_s
    user=User.find_by_email(from_address)
    if user 
     message=params[:html].to_s
     name=params[:subject].to_s
     project=Project.create(:user_id=>user.id, :name=>name, :is_public=>true)
     params[:to].each do |mail|
      if !mail.to_s.include?("p.rfmocha.com")
       invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
       ProjectMailer.delay.invite_people(user,invite)
      end
     end
     params[:cc].each do |mail|
      if !mail.to_s.include?("p.rfmocha.com")
       invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
       ProjectMailer.delay.invite_people(user,invite)
      end
     end
    end
   end
   

end
