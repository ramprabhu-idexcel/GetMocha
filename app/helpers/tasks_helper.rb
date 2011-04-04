module TasksHelper
  def form_content(count,content)
    if count>0
      content_tag(:span,count,:class=>'num-tasks')+content_tag(:span,'',:class=>"icon")+"#{content}"
    else
      content_tag(:span,'',:class=>"icon")+"#{content}"
    end
  end
  
  def link_to_all_tasks
    count=current_user.all_tasks.count
    link_to form_content(count,"All Task"),"#all-tasks",:class=>"all-tasks"
  end
  
  def link_to_my_tasks
    count=current_user.my_tasks.count
    link_to form_content(count,"My Task"),"#my-tasks",:class=>"my-tasks"
  end
  
  def link_to_starred_tasks
    count=current_user.starred_tasks.count
    link_to form_content(count,"Starred"),"#starred-tasks",:class=>"starred"
  end
end
