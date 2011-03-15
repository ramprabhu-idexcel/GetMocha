class ProjectsController < ApplicationController
	#~ before_filter :authenticate_user!
	layout "application"

	
	def new
	end
	
	def create
		@project=Project.new(params[:data])
		@project.status=ProjectStatus::ACTIVE
		@project.save
		@invites=Invitation.new(params[:data])
		@invites.save
		render :nothing=>true
	end
end
