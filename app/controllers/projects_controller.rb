class ProjectsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	 before_filter :authenticate_user!
	layout "application"

	
	def new
		@a=User.find(:all,:select=>[:first_name,:email])
		@tcMovies=[]
		@a.each do |f|
			@tcMovies<<"#{f.email}"
		end
		@movies=@tcMovies.to_a
	end
	
	def create		
		@project=Project.new(params[:data])
		@project.user_id=current_user
		@project.save
		@p_user=ProjectUser.new(:user_id => current_user.id, :project_id => @project.id, :status => true)
		@p_user.save
		@invites=Invitation.new(params[:data])
		@invites.project_id=@project.id
		@invites.save
		render :nothing=>true
	end
	def settings
		@projects=Project.find(:all, :conditions=>['status!=? AND user_id=?', 3, current_user.id])
		@completed_projects=Project.find_all_by_status_and_user_id(3,current_user.id)
	end
	def settings_pane
		@project=Project.find(params[:id])
		render :partial=>'settings_pane'
	end
	def remove_people
		@project=Project.find(params[:project_id])
		@user=User.find(params[:user])
		@proj_user=ProjectUser.find_by_project_id_and_status_and_user_id(@project.id,true,@user.id)
		if @proj_user
			@proj_user.update_attributes(:status=>false)
		else
			@guest_user=ProjectGuest.find_by_project_id_and_status_and_user_id(@project.id,true,@user.id)
			@guest_user.update_attributes(:status=>false)
		end
		render :partial=>'settings_pane'
	end
	def update_proj_settings
		@project=Project.find(params[:project_id])
		if params[:checked]
			checked=params[:checked]=="false" ? true : false
			@project.update_attributes(:is_public=>checked)
		elsif params[:project_name]
			@project.update_attributes(:name=>params[:project_name])
		elsif params[:proj_status]
			@project.update_attributes(:status=>params[:proj_status])
		elsif params[:email]
			@custom=CustomEmail.new(:custom_type=>"Message", :project_id=>@project.id, :email=>params[:email])
			@custom.save
		elsif params[:task_email]
			@custom=CustomEmail.new(:custom_type=>"Task", :project_id=>@project.id, :email=>params[:task_email])
			@custom.save
		elsif params[:remove_email]
			@custom=CustomEmail.find(params[:remove_email])
			@custom.destroy
		end
			render :partial=>'settings_pane'
		end
		def add_new
			render :partial=>'add_new'
		end
end
