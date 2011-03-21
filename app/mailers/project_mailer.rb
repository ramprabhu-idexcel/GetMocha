class ProjectMailer < ActionMailer::Base
  default :from => "mochabot@getmocha.com"
  
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
    @settings="localhost:3000/settings"
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
    @invite="http://localhost:3000/projects/verify_email/#{invite.verification_code}"
     mail(:to=>"#{user.email}", :subject=>"Verify Your Email Address on Mocha")
    @content_type="text/html"
  end
  def message_notification(user,to_user,message)
    @user = user
    @to_user = to_user
    @message=message
    @project=message.project
    mail(:to=>"#{to_user}", :reply_to=>"ctzm#{message.id}@rfmocha.com", :subject=>"#{user.first_name} posted a new message to #{to_user}")
    @content_type="text/html"
  end
  
  def invite_people(user,invite)
    @user=user
    @message=invite.message
    @invite_link="http://localhost:3000/projects/join_project/#{invite.invitation_code}"
    mail(:to=>"#{invite.email}", :subject=>"#{user.full_name} has invited you to join #{invite.project.name} on GetMocha.com")
    @content_type="text/html"
  end
end
