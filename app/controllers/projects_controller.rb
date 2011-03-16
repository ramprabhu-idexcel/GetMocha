class ProjectsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	 before_filter :authenticate_user!
	layout "application", :except=>['new']
	
	def new
		@users=User.find(:all,:select=>[:first_name,:email])
		@tcMovies=[]
		@users.each do |f|
			@tcMovies<<"#{f.email}"
		end
		render :partial => 'new'
		end
	
	def create		
		@project=Project.new(params[:data])
		@project.user_id=current_user.id
		project=@project.valid?
		@invites=Invitation.new(params[:data])
		@invites.project_id=@project.id
		invites=@invites.valid?
		invites=true if 
		errors=[]
      @project.errors.each_full{|msg| 
				errors<< msg 
			} 
      @invites.errors.each_full{|msg| 			if msg!="Email is too short (minimum is 6 characters)" && msg!="Email can't be blank" && msg!="Email is invalid"
			errors<< msg 
			end } 
		if project && invites
			@project.save
			@p_user=ProjectUser.new(:user_id => current_user.id, :project_id => @project.id, :status => true)
			@p_user.save
			@invites.save
			render :nothing=>true
		else
			render :update do |page|
				page.alert errors.join("\n")
			end
		end
		 
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
			@old_project=@project.name
			@project.update_attributes(:name=>params[:project_name])
			@project.project_users.each do |proj_user|
				ProjectMailer.delay.project_renamed(current_user,@old_project,@project.name,proj_user.user)
			end
			@project.project_guests.each do |proj_user|
				ProjectMailer.delay.project_renamed(current_user,@old_project,@project.name,proj_user.guest)
			end
		elsif params[:proj_status]
			@project.update_attributes(:status=>params[:proj_status])
			@project.project_users.each do |proj_user|
				if @project.status == 3
					ProjectMailer.delay.project_completed(@project,current_user,proj_user.user)
				else
					ProjectMailer.delay.project_activated(@project,current_user,proj_user.user)
				end
			end
		elsif params[:email]
			@custom=CustomEmail.new(:custom_type=>"Message", :project_id=>@project.id, :email=>params[:email])
			@custom.save
			ProjectMailer.delay.custom_email(current_user,@custom)
		elsif params[:task_email]
			@custom=CustomEmail.new(:custom_type=>"Task", :project_id=>@project.id, :email=>params[:task_email])
			@custom.save
			ProjectMailer.delay.custom_email(current_user,@custom)
		elsif params[:remove_email]
			@custom=CustomEmail.find(params[:remove_email])
			@custom.destroy
		end
			render :partial=>'settings_pane'
		end
		def add_new
			render :partial=>'add_new'
		end
		
		def verify_email
			@custom=CustomEmail.find_by_verification_code(params[:verification_code])
			@custom.update_attributes(:verification_code=>nil)
			redirect_to '/settings'
		end
end
