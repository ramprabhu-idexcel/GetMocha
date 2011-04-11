class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save','privacy','message_create_via_email','check_from_address_email']
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
	


def message_create_via_email
    from_address1=params[:from].to_s
if(from_address1.include?('<'))
from=from_address1.split('<')
from_add=from[1].split('>')
from_address1=from_add[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
    project_id=@dest_address[0].to_s
project_id=project_id.split('@')
project_id=project_id[0].split('-').last
project=Project.find(project_id)
#user=User.find_by_email(from_address)
#~ user=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>from_address}],:include=>:secondary_emails)
user=User.verify_email_id(from_address1)
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
guest=User.create(:email=>from_address1,:is_guest=>true, :password=>Encrypt.default_password) if !user
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
  info_message_project=message.project
  info_message_project.users.each do |user|
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

def new_project_via_email
    from_address=params[:from].to_s
if(from_address.include?('<'))
from_add=from_address.split('<')
from=from_add[1].split('>')
from_address=from[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
to_address=params[:to].split(',')
cc_address=params[:cc].split(',') if params[:cc]
user=User.find_by_email(from_address)
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
  def task_create_via_email
    from_address2=params[:from].to_s
    if(from_address2.include?('<'))
      from2=from_address2.split('<')
      from_add2=from2[1].split('>')
      from_address2=from_add2[0]
    end
    project_id=@dest_address[0].to_s
    project_id=project_id.split('@')
    project_id=project_id[0].split('-').last
    project=Project.find(project_id)
    #user=User.find_by_email(from_address)
    #~ user=User.find(:first,:conditions=>['users.email=:email or secondary_emails.email=:email',{:email=>from_address}],:include=>:secondary_emails)
    user=User.verify_email_id(from_address2)
    proj_user=ProjectUser.find_by_project_id_and_user_id(project.id, user.id) if user
    proj_user=ProjectGuest.find_by_project_id_and_guest_id(project.id, user.id) if !proj_user && user
    message=params[:html]
    title=params[:subject].to_s
    if message.include?("gmail_quote")
      message=message.split('<div class="gmail_quote">')[0]
    end
    if message.include?('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')
      message=message.split('<table cellspacing="0" cellpadding="0" border="0" ><tr><td valign="top" style="font: inherit;">')[1]
      message=message.split("</td></tr></table>")[0]
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
    task_list=TaskList.find_by_project_id_and_name(project.id, "Default TaskList")
    if !task_list
      task_list=TaskList.create(:project_id=>project.id, :user_id=>user.id, :name=>"Default TaskList")
    end
    #~ ex_task=Task.find_by_name(title)
    ex_task=Task.ex_task(title,project)
    if ex_task
    #~ existing_task=Task.find_by_sql("select * from tasks where name REGEXP '^"+title+"[[:digit:]]+'")
    existing_task=existing_task=Task.find_by_sql("select * from tasks where name REGEXP '^"+title+"[[:digit:]]+' and task_list_id='"+task_list.id.to_s+"'" )
      #~ existing_task=Task.find_by_sql("select * from task_lists,tasks where tasks.name REGEXP '^"+title+"[[:digit:]]+' and task_lists.project_id='"+project.id.to_s+"'")
      if existing_task && existing_task.count > 0
        ex_task=existing_task.last
        title=ex_task.name
        title_id=title.split(params[:subject].to_s)[1]
        title_id=title_id.to_i+1
        title=params[:subject].to_s+title_id.to_s
      else
        title=ex_task.name+"1"
      end
    end
    if ((!proj_user) && project.is_public? )
      guest=User.create(:email=>from_address2,:is_guest=>true, :password=>Encrypt.default_password) if !user
      if user
      task=Task.create(:name=>title,:description=>message,:user_id=>user.id,:task_list_id=>task_list.id)
      task.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>user.id)
      else
      task=Task.create(:name=>title,:description=>message,:user_id=>guest.id,:task_list_id=>task_list.id)
      task.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>guest.id)
      end
      if guest
      ProjectGuest.create(:guest_id=>guest.id,:project_id=>project.id)
      elsif user && user.is_guest
      ProjectGuest.create(:guest_id=>user.id,:project_id=>project.id)
      end
      elsif ((user && !user.is_guest && proj_user) || project.is_public?)
      task=Task.create(:name=>title,:description=>message,:user_id=>user.id,:task_list_id=>task_list.id)

    end
    logger.info user.inspect
    logger.info project.inspect
    logger.info task_list.inspect
    logger.info task.inspect
    logger.info title.inspect
    logger.info task.errors.inspect
    find_task_tasklist=task.task_list
    if task && find_task_tasklist.project
      find_task_tasklist.project.users.each do |user|
        activity=task.activities.create! :user=>user
        activity.update_attributes(:is_read=>(user.id==task.user_id),:is_subscribed=>true) if user.id==task.user_id
      end
    end
          if params[:attachments] && params[:attachments].to_i > 0
        for count in 1..params[:attachments].to_i
          attach=task.attachments.create(:uploaded_data => params["attachment#{count}"])
        end
      end
    #~ task.send_task_notification_to_team_members(user,@notify,@tasks)
  end

def reply_to_message_via_email
from_address_reply=params[:from].to_s
if(from_address_reply.include?('<'))
from_reply=from_address_reply.split('<')
from_add_reply=from_reply[1].split('>')
from_address_reply=from_add_reply[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
message_id=@dest_address[0].to_s.split('@')
message_id=message_id[0].split('ctzm')
message_id=message_id[1]
message=Message.find(message_id)
project=Project.find(message.project_id)
user=User.find_by_email(from_address_reply)
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

def reply_to_task_via_email
from_address_reply_task=params[:from].to_s
if(from_address_reply_task.include?('<'))
from_address_task=from_address_reply_task.split('<')
from_reply_task=from_address_task[1].split('>')
from_address_reply_task=from_reply_task[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
message_id=@dest_address[0].to_s.split('@')
message_id=message_id[0].split('ctzt')
message_id=message_id[1]
task=Task.find(message_id)
project=Project.find(task.project_id)
user=User.find_by_email(from_address_reply_task)
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
comment=Comment.create(:commentable_type=>"Task", :commentable_id=>task.id, :user_id=>user.id, :comment=>content)
task.activities.each do |activity|
activity.update_attributes(:is_read=>false)
end
end
if params[:attachments] && params[:attachments].to_i > 0
for count in 1..params[:attachments].to_i
attach=comment.attachments.create(:uploaded_data => params["attachment#{count}"])
end
end
end

def invite_via_email
from_address_invite=params[:from].to_s
if(from_address_invite.include?('<'))
from_invite=from_address_invite.split('<')
from_add_invite=from_invite[1].split('>')
from_address_invite=from_add_invite[0]
end
#~ from_address=check_from_address_email(params[:from].to_s)
to_address=params[:to].split(',')
cc_address=params[:cc].split(',') if params[:cc]
user=User.find_by_email(from_address_invite)
if user
message=params[:text]
name=params[:subject].to_s
#~ project=Project.create(:user_id=>user.id, :name=>name, :is_public=>true)
#~ ProjectUser.create(:user_id => user.id, :project_id => project.id, :status => true)
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

  	