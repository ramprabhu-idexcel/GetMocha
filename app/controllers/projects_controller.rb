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
		p current_user
#		@projects=current_user.projects if current_user
@projects=Project.all
		p @projects.inspect
	end
	def settings_pane
		p params[:project_id]
		@project=Project.find(params[:project_id])
		p @project
		#render :nothing=>true
		render :partial=>'settings_pane'
		#~ render :update do |page|
			#~ page.replace_html 'settings_pane', :partial=>'settings_pane'
		#~ end
	end
end
