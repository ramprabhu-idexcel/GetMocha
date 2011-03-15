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
	def update_proj_settings
		@project=Project.find(params[:project_id])
		if params[:change_field]=="public_access"
			checked=params[:checked]=="false" ? true : false
			p checked
			@project.update_attributes(:is_public=>checked)
		end
			render :partial=>'settings_pane'
	end
end
