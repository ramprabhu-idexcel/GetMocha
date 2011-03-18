class UserMailer < ActionMailer::Base
  default :from => "mochabot@getmocha.com"
   def verify_secondary_email(email,code)
    @url=verify_secondary_email_url(:verification_code=>code)
    mail(:to=>email, :subject=>"Verify Your Email Address on Mocha")
    @content_type="text/html"
   end
   # Method added for postfix functionality
   def receive(email)
    
  
    if email && email.from && email.from.first
     @dest_address=email.to.first.to_s
     logger.info @dest_address
     if @dest_address.include?("@p.rfmocha.com")
       new_post_create_via_mail(email)
     elsif @dest_address.include?("@m.rfmocha.com")
       new_message_create_via_mail(email)
     elsif @dest_address.downcase.include?("ctzm")
       comment_for_message_via_mail(email)
     end
    end
    
   end
   
   def new_post_create_via_mail(email)
    from_address=email.from.first.to_s
    user=User.find_by_email(from_address)
    if user 
     message=email.body.to_s
     name=email.subject.to_s
     project=Project.create(:user_id=>user.id, :name=>name, :is_public=>true)
     email.to.each do |mail|
      if !mail.to_s.include?("p.rfmocha.com")
       invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
       ProjectMailer.delay.invite_people(user,invite)
      end
     end
     email.cc.each do |mail|
      if !mail.to_s.include?("p.rfmocha.com")
       invite=Invitation.create(:email=>mail,:message=>message,:project_id=>project.id)
       ProjectMailer.delay.invite_people(user,invite)
      end
     end
    end
   end
   
   def new_message_create_via_mail(email)
    from_address=email.from.first.to_s
    project_id=email.to.first.to_s
    project_id=project_id.split('@')
    project_id=project_id[0].split('-').last
    project=Project.find(project_id)
    user=User.find_by_email(from_address)
    if ((user && !user.is_guest) || project.is_public?)
    #~ message=email.body("Attachment: (unnamed)") if email.body
    #~ logger.info message.inspect
    #~ message=message.split("Attachment: (unnamed)")
    #~ logger.info message.inspect
    #~ message=message.to_s
    #~ logger.info message.inspect
    message=email.body.to_s
     name=email.subject.to_s
     message=Message.create(:user_id=>user.id, :project_id=>project.id, :subject=>name, :message=>message)
     activity=Activity.create(:user_id=>user.id, :resource_type=>"Message", :resource_id=>message.id)
     #~ logger.info email.has_attachments?
     #~ if email.has_attachments?
      #~ for attachment in email.attachments 
       #~ logger.info "***************************************"
       #~ logger.info attachment.inspect
       #~ logger.info "***************************************"
         #~ a=Attachment.create(:uploaded_data => attachment) 
         #~ logger.info a.inspect
                #~ logger.info "***************************************"
       #~ end
     #~ end
    end
   end
   
   def comment_for_message_via_mail(email)
    from_address=email.from.first.to_s
    message_id=email.to.first.gsub(/[a-z]+/, "")
    user=User.find_by_email(from_address)
    message=Message.find(message_id)
    project=Project.find(message.project_id)
    content=email.body.to_s
    if user
     comment=Comment.create(:commentable_type=>"Message", :commentable_id=>message.id, :user_id=>user.id, :comment=>content)
     message.activities.each do |activity|
      activity.update_attributes(:is_read=>false)
     end
    end
   end
   
end