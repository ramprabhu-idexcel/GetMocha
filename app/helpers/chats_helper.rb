module ChatsHelper
  def project_link(project)
    count=0
    unless count.zero?
      link_to content_tag(:span,count,:class=>"num-unread")+content_tag(:span,'',:class=>"icon")+project.name,"##{project.id}",:class=>"project has-unread"
    else
      link_to content_tag(:span,'',:class=>"icon")+project.name,"##{project.id}",:class=>"project"
    end
  end
end
