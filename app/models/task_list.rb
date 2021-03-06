class TaskList < ActiveRecord::Base
	belongs_to :user
	has_many :tasks
	belongs_to :project
	has_many :project_guests,:through=>:project
	validates :name, :presence   => true,:length=>{:within=> 1...25}
  validate :unique_name,:on=>:create
  def unique_name
    project=self.project
		find_project_tasklists=project.task_lists
    task_list=find_project_tasklists.find(:first,:conditions=>['task_lists.name=?',self.name])
    task_list ? errors.add(:name,"A task list with that name already exists") : true
  end
end
