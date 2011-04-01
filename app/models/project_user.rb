class ProjectUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  	def is_member?(user_id,project_id)
		project_users.find(:first, :conditions=>['user_id=? AND status=? AND project_id=?', user_id,true,project_id]).present?
	end
end
