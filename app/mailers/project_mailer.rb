class ProjectMailer < ActionMailer::Base
  default :from => "from@example.com"
  
def project_renamed(user,project,to_user)
    @user = user
    mail(:from=>"#{user.email}", :to=>"#{to_user.email}", :subject=>"[Project Name] Project Has Been Renamed to [New Project Name]")
end
end
