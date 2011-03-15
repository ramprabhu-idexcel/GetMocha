class ProjectsController < ApplicationController
	#~ before_filter :authenticate_user!
	layout "application"

	
	def new
	end
	
	def create		
		@project=Project.new(params[:data])
		@project.status=ProjectStatus::ACTIVE
		@project.user_id=current_user
		@project.save
		@id=Project.last
		@invites=Invitation.new(params[:data])
		@invites.project_id=@id.id
		@invites.save
		render :nothing=>true
	end
end
