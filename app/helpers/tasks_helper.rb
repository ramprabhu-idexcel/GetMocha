module TasksHelper
  def form_content(count,content)
    if count>0
      content_tag(:span,count,:class=>'num-tasks')+content_tag(:span,'',:class=>"icon")+"#{content}"
    else
      content_tag(:span,'',:class=>"icon")+"#{content}"
    end
  end
  def link_to_all_tasks
    count=current_user.find_all_tasks.count
    link_to form_content(count,"All Tasks"),"#all_tasks",:class=>"all-tasks open",:id=>"all_tasks"
  end
  def link_to_my_tasks
    count=current_user.find_my_tasks(nil).count
    link_to form_content(count,"My Tasks"),"#my_tasks",:class=>"my-tasks", :id=>"my_tasks"
  end
  def link_to_starred_tasks
    count=current_user.starred_task_count
    link_to form_content(count,"Starred"),"#starred_tasks",:class=>"starred starred_count",:id=>"starred_tasks"
  end
  def link_to_completed_tasks
    count=current_user.completed_tasks(nil,nil).count
    if(count>0)
      link_to form_content(count,"Completed"),"#completed_tasks",:class=>"completed",:id=>"completed_tasks"
    else
      link_to form_content(count,"Completed"),"#completed_tasks",:class=>"completed",:style=>"display:none;",:id=>"completed_tasks"
    end
  end
  def project_tab(project)
    content_tag(:div,'',:class=>'project',:id=>"tpi#{project.id}") do
      content_tag(:span,'',:class=>'icon')+content_tag(:span,content_tag(:span,'',:class=>'icon')+project.name,:class=>'project-title')+task_list_project(project.task_lists)+content_tag(:div,'',:class=>'clear-fix')
    end
  end
  def task_list_project(task_lists)
    content_tag :ul do
      task_lists.collect {|task_list| concat(content_tag(:li, content_tag(:span,task_list.name)))}
    end
  end
end
