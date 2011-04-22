namespace :due_date_notification do
  task :late_task => :environment do
    tasks=Task.late_tasks
    tasks.each do |task|
      project_guests=task.task_list.project_guests.map(&:user_id)
      task.subscribed_users.each do |activity|
        ProjectMailer.task_late(task,activity.user).deliver unless project_guests.include?(activity.user_id)
      end
    end
  end
  task :task_due => :environment do
    tasks=Task.task_due
    tasks.each do |task|
      project_guests=task.task_list.project_guests.map(&:user_id)
      task.subscribed_users.each do |activity|
        ProjectMailer.task_due(task,activity.user).deliver unless project_guests.include?(activity.user_id)
      end
    end
  end
end