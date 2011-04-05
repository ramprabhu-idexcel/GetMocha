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
    link_to form_content(count,"All Tasks"),"#all_tasks",:class=>"all-tasks"
  end
  def link_to_my_tasks
    count=current_user.my_tasks.count
    link_to form_content(count,"My Tasks"),"#my_tasks",:class=>"my-tasks"
  end
  def link_to_starred_tasks
    count=current_user.starred_tasks.count
    link_to form_content(count,"Starred"),"#starred_tasks",:class=>"starred"
  end
  def link_to_completed_tasks
    count=current_user.completed_tasks.count
    link_to form_content(count,"Completed"),"#completed_tasks",:class=>"completed"
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
