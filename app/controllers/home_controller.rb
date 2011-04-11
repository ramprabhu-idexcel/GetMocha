class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save','privacy']
	before_filter :check_from_address_email,:only=>['message_create_via_email']
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
	
	  def check_from_address_email
  logger.info "********************************"
logger.info params[:from].inspect
logger.info "********************************"
@from_address=(params[:from].to_s)

if(@from_address.include?('<'))
@from_address=@from_address.split('<')
@from_address=@from_address[1].split('>')
@from_address=@from_address[0]
end
logger.info @from_address.inspect
logger.info "********************************"

end

def message_create_via_email
    from_address=params[:from].to_s
if(from_address.include?('<'))
from_address=from_address.split('<')
from_address=from_address[1].split('>')
from_address=from_address[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
    project_id=@dest_address[0].to_s
project_id=project_id.split('@')
project_id=project_id[0].split('-').last
project=Project.find(project_id)
#user=User.find_by_email(from_address)
#~ user=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>from_address}],:include=>:secondary_emails)
user=User.verify_email_id(from_address)
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
if ((!proj_user) && project.is_public? )
guest=User.create(:email=>from_address,:is_guest=>true, :password=>Encrypt.default_password) if !user
if user
message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>user.id)
else
message=Message.create(:user_id=>guest.id, :project_id=>project.id, :subject=>name, :message=>message)
#~ message.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>guest.id)
end
if guest
ProjectGuest.create(:guest_id=>guest.id,:project_id=>project.id)
elsif user && user.is_guest
ProjectGuest.create(:guest_id=>user.id,:project_id=>project.id)
end
elsif ((user && !user.is_guest && proj_user) || project.is_public?)
message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
#~ activity=Activity.create(:user_id=>user.id, :resource_type=>"Message", :resource_id=>message.id)

      end
if message && message.project
message.project.users.each do |user|
activity=message.activities.create! :user=>user
activity.update_attributes(:is_read=>(user.id==message.user_id),:is_subscribed=>true) if user.id==message.user_id
end
end
if params[:attachments] && params[:attachments].to_i > 0
for count in 1..params[:attachments].to_i
attach=message.attachments.create(:uploaded_data => params["attachment#{count}"])
end
end
end

	
end

  	