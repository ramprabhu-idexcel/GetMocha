class ProjectMailer < ActionMailer::Base
  default :from => "mochabot@getmocha.com", :except=>['message_notification','message_reply']
    def project_renamed(user,old_project,new_project,to_user)
      @user = user
      @old_project=old_project
      @new_project=new_project
      mail(:to=>"#{to_user.email}", :subject=>"#{old_project} Project Has Been Renamed to #{new_project}")
      @content_type="text/html"
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
     mail(:to=>"#{user.email}", :subject=>"Verify Your Email Address on Mocha")
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
    if custom_email.empty?
      from=custom_email.email
    else
     from="mochabot@getmocha.com"
    end
    subscribed_list=message.activities.find(:all, :conditions=>['is_subscribed=?', true])
    @people=[]
    if subscribed_list
    subscribed_list.each do|activity|
      @people<<activity.user.full_name<<"," if activity.user
     end
    end
    mail(:from=>"#{from}", :to=>"#{to_user}", :reply_to=>"ctzm#{message.id}@#{APP_CONFIG[:reply_email]}", :subject=>"#{user.first_name} posted a new message to #{to_user}")
    @content_type="text/html"
  end
  def invite_people(user,invite)
    @user=user
    @message=invite.message
    @invite_link="#{APP_CONFIG[:site_url]}/projects/join_project/#{invite.invitation_code}"
    mail(:to=>"#{invite.email}", :subject=>"#{user.full_name} has invited you to join #{invite.project.name} on GetMocha.com")
    @content_type="text/html"
  end
  def message_reply(user,comment)
    @user=user
    @comment=comment
     custom_email=@comment.commentable.project.custom_emails.find(:first, :conditions=>['custom_type=? AND verification_code IS NULL', "Message"])
    if custom_email.empty?
      from=custom_email.email
    else
     from="mochabot@getmocha.com"
    end
    @message=comment.commentable
    mail(:from=>"#{from}",  :to=>@user.email,:reply_to=>"ctzm#{@message.id}@#{APP_CONFIG[:reply_email]}", :subject=>@message.subject)
    @content_type="text/html"
  end
end
