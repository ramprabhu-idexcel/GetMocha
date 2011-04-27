class Project < ActiveRecord::Base
	Message_email="@#{APP_CONFIG[:message_email]}"
	Task_email="@#{APP_CONFIG[:task_email]}"
  has_many :task_lists
	has_many :tasks, :through=>:task_lists
	has_many :project_users
	has_many :project_guests
	has_many :users, :through=> :project_users
  has_many :guests,:through=>:project_guests,:source => :user
	has_many :activities, :through => :messages, :dependent=>:destroy
	has_many :messages
	has_many :comments#, :through=>:activities
	has_many :custom_emails
	has_many :chats
  has_many :recent_chats, :class_name => 'Chat', :order => 'updated_at DESC', :limit => 20
	has_many :invitations
  belongs_to :owner,:class_name=>"User"
	attr_accessible :name,:status,:message_email_id,:task_email_id,:is_public,:user_id
	validates :name, :presence   => true
	validates :name, :length     => { :within => 4..40, :message=>"Please enter a project name with more than 3 characters and less than 20 characters" }
	after_create :create_email_ids
	scope :all_projects,:conditions=>['status!=?',ProjectStatus::DELETED]
  #~ named_scope :verify_project,:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users
  def all_task_ids
    tasks.map(&:id)
  end
  def all_uncompleted_task_ids
    tasks.uncompleted_tasks_id
  end
  def all_members
    User.all_members(self.id)
  end
  def online_members
    User.online_members(self.id)
  end
  def self.user_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND project_users.status=?',user_id,true],:include=>:project_users)
  end
	
	def self.user_active_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status!=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
	
	def self.user_completed_projects(user_id)
    find(:all,:conditions=>['project_users.user_id=? AND projects.status=? AND project_users.status=?',user_id,3,true],:include=>:project_users)
  end
  def  create_email_ids
		self.update_attributes(:status=>ProjectStatus::ACTIVE, :message_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Message_email, :task_email_id=>"#{self.name.gsub(" ","")}-#{self.id}"+Task_email)
	end
	def is_member?(user_id)
		project_users.is_project_member?(user_id)
	end
		def has_custom_message_id?
		custom_emails.find_by_custom_type("Message").present?
	end
	
	def has_custom_task_id?
		custom_emails.find_by_custom_type("Task").present?
	end
  def modified_task_email_id
    "#{task_email_id.split('@')[0]}@#{APP_CONFIG[:task_email]}"
  end
  def modified_message_email_id
    "#{message_email_id.split('@')[0]}@#{APP_CONFIG[:message_email]}"
  end
  def project_unread_message(user_id)
    activities.where('activities.user_id=? AND is_read=? AND is_delete=?',user_id,false,false)
  end

  def project_unread_message_count(user_id)
    project_unread_message(user_id).count
  end
	def project_member?(user_id)
    project_guests.find_by_guest_id_and_status(user_id,true).present? || project_users.find_by_user_id_and_status(user_id,true).present?
  end
	def is_a_guest?(user_id)
    guest_object(user_id).present?
  end
	def guest_object(user_id)
    project_guests.find_by_guest_id(user_id)
  end
	def all_active_projects
    find(:all,:conditions=>['projects.status!=? AND project_users.status=?',ProjectStatus::COMPLETED,true],:include=>:project_users)
  end
  def all_completed_projects
    find(:all,:conditions=>['projects.status=? AND project_users.status=?',ProjectStatus::COMPLETED,true],:include=>:project_users)
  end
		def invite_people_settings
		@invite=Invitation.new(:project_id=>params[:project_id], :name=>params[:name], :email=>params[:email], :message=>params[:message])
		@invite.save
		@project=Project.find(params[:project_id])
		if @invite.valid?
			ProjectMailer.delay.invite_people(current_user,@invite)
			render :nothing=>true
		else
			errors=[]
			if params[:email].blank?
				errors<<"Please enter email address"
			elsif	@invite.errors[:email][0]=="is too short (minimum is 6 characters)"
				errors<<"Please enter email minimum 6 characters"
			elsif @invite.errors[:email][0]=="is invalid"
				errors<<"Please enter valid email address"
			end
			render :update do |page|
				page.alert errors
			end
		end
	end
  def join_project
		@invite=Invitation.find_by_invitation_code(params[:invitation_code])
		@user=User.find_by_email(@invite.email)
    project=@invite.project
		if @user && @user.is_guest == false
      project.guest_object(@user.id).delete if project.is_a_guest?(@user.id)
			@user.guest_update_message(@invite.project_id)
			@invite.update_attributes(:invitation_code=>nil, :status=>true)
			redirect_to "/"
		else
			
      project.guest_object(@user.id).delete if project.is_a_guest?(@user.id)
			@user.guest_update_message(@invite.project_id)
			@invite.update_attributes(:invitation_code=>nil)
			redirect_to new_user_registration_path
		end
  end
	def find_project_name
    @project=Project.find_by_id(params[:project_id]) if params[:project_id]
    session[:project_name]=@project.name if @project
    session[:project_selected]=@project.id if @project
  end
	def file_download_from_email
		attachment=Attachment.find(params[:id])
		if RAILS_ENV=="development"
		send_file "#{RAILS_ROOT}/public"+attachment.public_filename
		else
			s3_connect
			s3_file=S3Object.find(attachment.public_filename.split("/#{S3_CONFIG[:bucket_name]}/")[1],"#{S3_CONFIG[:bucket_name]}")
			send_data(s3_file.value,:url_based_filename=>true,:filename=>attachment.filename,:type=>attachment.content_type)			
		end		
	end
	def self.verify_project(current_user)
		find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=?',current_user.id],:include=>:project_users)
	end	
    def team_members
    User.project_team_members(self.id)
  end
  def members_list
    users=[]
    team_members.collect{|user| users<<{:id=>user.id,:name=>user.full_name}}
    users
  end
	def self.p_count_active
		find(:all, :conditions=>['status=? OR status=?',1,2])
  end
	def self.p_count_completed
		find(:all, :conditions=>['status=?',3])
	end	
	def self.check_project_users(current_user)
		find(:all,:select=>{[:name],[:id]},:conditions=>['project_users.user_id=? AND projects.status!=?',current_user.id,ProjectStatus::COMPLETED],:include=>:project_users)
	end	
  def next_chats(offset)
    Chat.find_next_chats(self.id,offset)
  end
  def delete_guest(user_id)
    self.guest_object(user_id).delete if self.is_a_guest?(user_id)
  end
	
	def self.via_email_contents(params)
		  @dest_address=params[:to].split(',')
	  dest_address=@dest_address[0]
			if  dest_address.include?('<')
				@dest_address=@dest_address.split('<')
				@dest_address=@dest_address[1].split('>')
				@dest_address=@dest_address[0].to_s
			end
			if @dest_address[0].to_s.include?("#{APP_CONFIG[:project_email]}")
				new_project_via_email(params)
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:message_email]}")
				message_create_via_email(params)
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:task_email]}")
				task_create_via_email(params)
			elsif @dest_address[0].to_s.include?("#{APP_CONFIG[:invite_email]}")
				invite_via_email(params)
			elsif @dest_address[0].to_s.include?("ctzm")
				reply_to_message_via_email(params)
			elsif @dest_address[0].to_s.include?("ctzt")
				reply_to_task_via_email(params)
			end
		end
		
		
def self.message_create_via_email(params)
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

def self.new_project_via_email(params)
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
  def task_create_via_email(params)
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
    ex_task=Task.find_by_name(title)
    #~ ex_task=Task.ex_task(title,project)
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
      task.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>user.id,:is_assigned=>true)
      else
      task=Task.create(:name=>title,:description=>message,:user_id=>guest.id,:task_list_id=>task_list.id)
      task.activities.create(:is_subscribed=>true,:is_delete=>true,:user_id=>guest.id,:is_assigned=>true)
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
    logger.info message.inspect
    logger.info task.errors.inspect
    find_task_tasklist=task.task_list
    if task && find_task_tasklist.project
      find_task_tasklist.project.users.each do |user|
        activity=task.activities.create! :user=>user
        activity.update_attributes(:is_read=>(user.id==task.user_id),:is_subscribed=>true,:is_assigned=>true) if user.id==task.user_id
      end
    end
          if params[:attachments] && params[:attachments].to_i > 0
        for count in 1..params[:attachments].to_i
          attach=task.attachments.create(:uploaded_data => params["attachment#{count}"])
        end
      end
    #~ task.send_task_notification_to_team_members(user,@notify,@tasks)
  end

def reply_to_message_via_email(params)
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

def reply_to_task_via_email(params)
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
tl=task.task_list
project=Project.find_by_id(tl.project_id)
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


end
