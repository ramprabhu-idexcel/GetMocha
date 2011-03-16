class ProjectMailer < ActionMailer::Base
  default :from => "from@example.com"
  
  def project_renamed(user,old_project,new_project,to_user)
      @user = user
      @old_project=old_project
      @new_project=new_project
      mail(:from=>"#{user.email}", :to=>"#{to_user.email}", :subject=>"#{old_project} Project Has Been Renamed to #{new_project}")
  end
  
  def project_completed(project, user, to_user)
    @user = user
    @to_user = to_user
    @settings="localhost:3000/settings"
    mail(:from=>"#{user.email}", :to=>"#{to_user.email}", :subject=>"#{project.name} has been completed")
    @content_type="text/html"
  end
  
  def project_activated(project, user, to_user)
    @user = user
    @to_user = to_user
    @project=project
    mail(:from=>"#{user.email}", :to=>"#{to_user.email}", :subject=>"#{project.name} Project Is Now In Progress")
    @content_type="text/html"
  end
end
