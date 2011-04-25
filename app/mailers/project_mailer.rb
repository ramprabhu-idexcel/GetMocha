class ProjectMailer < ActionMailer::Base
  default :from => "mochabot@getmocha.com", :except=>['message_notification','message_reply']
    def project_renamed(user,old_project,new_project,to_user)
      @user = user
      @old_project=old_project
      @new_project=new_project
      mail(:to=>"#{to_user.email}", :subject=>"#{old_project} Project Has Been Renamed to #{new_project}",:content_type=>"text/html")
    end
  def project_completed(project, user, to_user)
    @user = user
    @to_user = to_user
    @settings="#{APP_CONFIG[:site_url]}/settings"
    mail(:to=>"#{to_user.email}", :subject=>"#{project.name} has been completed")
    @content_type="text/html"
  end
  def project_activated(project, user, to_user)
    @user = user
    @to_user = to_user
    @project=project
    @user = user
    @to_user = to_user
  end
  def custom_email(user, invite)
    @user = user
    @verify_email=invite.email
    @invite="#{APP_CONFIG[:site_url]}/projects/verify_email/#{invite.verification_code}"
     mail(:to=>"#{user.email}", :subject=>"Verify Your Email Address on Mocha",:content_type=>"text/html")
    @content_type="text/html"
  end
  def message_notification(user,to_user,message)
     @user = user
    if to_user.include?(",")
      to_user = to_user.split(',')
      to_user = to_user[0]
    else
      to_user=to_user
    end
    @existing_user=User.find_by_email(to_user)
    @message=message
    @project=message.project
    custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Message"])
    if custom_email && !custom_email.blank?
      from=custom_email.email
    else
     from="mochabot@getmocha.com"
    end
    subscribed_list=message.activities.find(:all, :conditions=>['is_subscribed=?', true])
    @people=[]
    if subscribed_list
    subscribed_list.each do|activity|
      activity_name=activity.user
      @people<<activity_name.full_name if activity.user && !activity_name.first_name.nil?
    end
    @people=@people.join(',')
   end
    mail(:from=>"#{from}", :to=>"#{to_user}", :reply_to=>"ctzm#{message.id}@#{APP_CONFIG[:reply_email]}", :subject=>"#{user.first_name} posted a new message to #{to_user}",:content_type=>"text/html")
    @content_type="text/html"
  end
  def invite_people(user,invite)
    @user=user
    @message=invite.message
    @invite_link="#{APP_CONFIG[:site_url]}/projects/join_project/#{invite.invitation_code}"
    mail(:to=>"#{invite.email}", :subject=>"#{user.full_name} has invited you to join #{invite.project.name} on GetMocha.com",:content_type=>"text/html")
    @content_type="text/html"
  end
  def chat_invite(user,project,email,message)
    @user=user
    @message=message if message.present?
    @message="#{user.full_name} wants to chat with you on Mocha about #{project.name}." unless @message
    @invite_link="#{APP_CONFIG[:site_url]}/chat_invite/#{project.id}"
    mail(:to=>"#{email}", :subject=>"#{user.full_name}  wants to chat with you on Mocha",:content_type=>"text/html")
    @content_type="text/html"
  end
  def message_reply(user,comment)
    @user=user
    @comment=comment
    message=@comment.commentable
    project=message.project
    custom_email=project.message_email_id
    if custom_email && !custom_email.blank?
      from=custom_email.email
    else
     from="mochabot@getmocha.com"
    end
    @message=comment.commentable
    mail(:from=>"#{from}",  :to=>@user.email,:reply_to=>"ctzm#{@message.id}@#{APP_CONFIG[:reply_email]}", :subject=>@message.subject,:content_type=>"text/html")
    @content_type="multipart/html"
  end
  def task_reply(user,comment)
    @user=user
    @comment=comment
    task=@comment.commentable
    check_task_task_list=task.task_list
    @project=check_task_task_list.project
    #custom_emails=@project.task_email_id
    @custom_email=@project.custom_emails.find(:first,:conditions=>['custom_type=? AND verification_code IS NOT NULL','Task'])
    if @custom_email && !@custom_email.empty?
      from=@custom_email
    else
     from=@project.task_email_id
    end
    @task=comment.commentable
    mail(:from=>"#{from}",  :to=>@user.email,:reply_to=>"ctzt#{@task.id}@#{APP_CONFIG[:reply_email]}", :subject=>"#{@project.name} Task - Re: #{task.name}",:content_type=>"text/html")
    @content_type="multipart/html"
  end
 	def author
    	"#{self.user.name} at  #{self.created_at.strftime('%I:%M %p')} on #{self.created_at.strftime('%B %d, %Y') }"
    end
  def task_assign_notification(user,task)
    @user = user
    @task=task
    task_list=task.task_list
    @project=task_list.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    from = @custom_email && !@custom_email.empty? ? custom_email.email : @project.task_email_id
    @content_type="text/html"
    @people=task.subscribed_user_names
    details=task.mail_content(user.id)
    @task_details=details.first
    @footer_details=details.last
    mail(:from=>from,:to=>user.email, :reply_to=>"ctzt#{task.id}@#{APP_CONFIG[:reply_email]}", :subject=>"#{@project.name} Task - #{task.name}",:content_type=>"text/html")
  end
  def task_notification(user,task)
    @user = user
    @task=task
    task_notification_task_tasklist=task.task_list
    @project=task_notification_task_tasklist.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>user.email, :reply_to=>"ctzt#{@task.id}@#{APP_CONFIG[:reply_email]}",:subject=>"#{@project.name} Task - #{task.name}",:content_type=>"text/html")
  end
  def task_reassigned(task,user)
    @user=user
    @task=task
    task_task_list_for_reassigned=task.task_list
    @project=task_task_list_for_reassigned.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>"#{user.email}", :reply_to=>"ctzt#{@task.id}@#{APP_CONFIG[:reply_email]}",:subject=>"Task Reassigned - #{@project.name} Re: #{@task.name}",:content_type=>"text/html")
  end
  def task_completed(task,users)
    @user=users
    @task=task
    task_completed_task_tasklist=task.task_list
    @project=task_completed_task_tasklist.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>@user.user.email, :subject=>"Task Completed - #{@project.name} Re: #{@task.name}",:content_type=>"text/html")
  end
  def task_moved_other_task_list(task,user_act)
    @user=user_act
    @task=task
    task_moved_other_task_list_task_tasklist=task.task_list
    @project=task_moved_other_task_list_task_tasklist.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>@user.user.email, :subject=>"Task Moved To New Tasklist",:content_type=>"text/html")
    end
  def task_due(task,user)
    @user=user
    @task=task
    task_due_task_tasklist=task.task_list
    @project=task_due_task_tasklist.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>user.email,:reply_to=>"ctzt#{@task.id}@#{APP_CONFIG[:reply_email]}", :subject=>"Task Due - #{@project.name} Re: #{@task.name}",:content_type=>"text/html")
  end
  def late_task(task,user)
    @user=user
    @task=task
    late_task_task_tasklist=task.task_list
    @project=late_task_task_tasklist.project
    @custom_email=@project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Task"])
    mail(:to=>user.email,:reply_to=>"ctzt#{@task.id}@#{APP_CONFIG[:reply_email]}", :subject=>"Task Late (1 Day Late) - #{@project.name} Re: #{@task.name}",:content_type=>"text/html")
  end

end
