class ProjectMailer < ActionMailer::Base
  default :from => "from@example.com"
  
def project_renamed(user,old_project,new_project,to_user)
    @user = user
    @old_project=old_project
    @new_project=new_project
    mail(:from=>"#{user.email}", :to=>"#{to_user.email}", :subject=>"#{old_project} Project Has Been Renamed to #{new_project}")
end
end
