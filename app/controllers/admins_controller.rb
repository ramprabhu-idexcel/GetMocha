class AdminsController < ApplicationController
	layout "admin_application",:except=>["new","reset_password"]
	#layout 'before_login', :only=>["new","reset_password"]
	def new
		
	end
	def admin_panel
		layout 'before_login'
		p params.inspect
		if params[:email]=='admin@getmocha.com' && params[:password]=='admin123'
			redirect_to 'settings'
			else
				render :nothing=>true
			end
			end
	def settings
		
	end
	def reset_password
		
	end
	def users
		@users=User.find(:all)
		render :partial=>'users'
	end
	def projects
		@projects=Project.find(:all)
			render :partial=>'projects'
	end
	def analetics
		@p_active_count=Project.find(:all, :conditions=>['status=?',true])
		@p_completed_count=Project.find(:all, :conditions=>['status=?',false])
		@m_count=Message.find(:all)
		@tl_count=TaskList.find(:all)
		@t_count=Task.find(:all)
		@u_count=User.find(:all,:conditions=>['is_guest=?',false])
		@g_count=User.find(:all,:conditions=>['is_guest=?',true])
		render :partial=>'analetics'
	end
		def remove_user
			puts params.inspect
			@user=User.delete(params[:id])
			@users=User.find(:all)
			
render :partial=>'users'
		end
		def remove_project
			p params.inspect
			@project=Project.delete(params[:id])
			@projects=Project.find(:all)
			render :partial=>'projects'
end
end