module ChatsHelper
  def project_link(project)
    count=0
    unless count.zero?
      link_to content_tag(:span,count,:class=>"num-unread")+content_tag(:span,'',:class=>"icon")+project.name,"##{project.id}",:class=>"project has-unread",:id=>"cp#{project.id}"
    else
      link_to content_tag(:span,'',:class=>"icon")+project.name,"##{project.id}",:class=>"project",:id=>"cp#{project.id}"
    end
  end
end
