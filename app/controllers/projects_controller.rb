class ProjectsController < ApplicationController
	#~ before_filter :authenticate_user!
	layout "application"

	
	def new
	end
	
	def create		
		@project=Project.new(params[:data])
		@project.user_id=current_user
		@project.save
		@invites=Invitation.new(params[:data])
		@invites.project_id=@project.id
		@invites.save
		render :nothing=>true
	end
	def settings
	end
end
