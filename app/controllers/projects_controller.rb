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
		@projects=Project.all
	end
	def settings_pane
		@project=Project.find(params[:project_id])
		render :partial=>'settings_pane'
	end
	def remove_people
		@project=Project.find(params[:project_id])
		@user=User.find(params[:user])
		@user.update_attributes(:status => false)
		render :partial=>'settings_pane'
	end
end
