class ProjectUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  	#~ def self.is_member?(user_id,project_id)
		#~ project_users.find(:first, :conditions=>['user_id=? AND status=? AND project_id=?', user_id,true,project_id]).present?
	#~ end
  def self.is_project_member?(user_id)
		find(:first, :conditions=>['user_id=? AND status=?', user_id,true]).present?
	end
end
