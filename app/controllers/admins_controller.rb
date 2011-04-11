class AdminsController < ApplicationController
	layout "admin_application",:except=>["new"]
	#layout 'before_login', :only=>["new","reset_password"]
	def new

	end
	def admin_panel
		layout 'before_login'
		if params[:email]=='admin@getmocha.com' && params[:password]=='admin123'
			redirect_to 'settings'
		else
			render :nothing=>true
		end
	end
	def settings
		render "settings"
	end
	def users
		@users=User.find(:all)
		render :partial=>'users',:locals=>{:users=>@users}
	end
	def projects
		@projects=Project.find(:all)
			render :partial=>'projects',:locals=>{:projects=>@projects}
	end
	def analetics
		#~ @p_active_count=Project.find(:all, :conditions=>['status=?',true])
		@p_active_count=Project.p_count_active
		#~ @p_completed_count=Project.find(:all, :conditions=>['status=?',false])
		@p_completed_count=Project.p_count_completed
		@m_count=Message.find(:all)
		@tl_count=TaskList.find(:all)
		@t_count=Task.find(:all)
		#~ @u_count=User.find(:all,:conditions=>['is_guest=?',false])
		@u_count=User.u_count_val
		#~ @g_count=User.find(:all,:conditions=>['is_guest=?',true])
		@g_count=User.g_count_data
			render :partial=>'analetics',:locals=>{:p_active_count=>@p_active_count,:p_completed_count=>@p_completed_count,:m_count=>@m_count,:tl_count=>@tl_count,:t_count=>@t_count,:u_count=>@u_count,:g_count=>@g_count}
	end
	def remove_user
		puts params.inspect
		@user=User.delete(params[:id])
		@users=User.find(:all)
		render :partial=>'users',:locals=>{:users=>@users}
	end
	def remove_project
		@project=Project.delete(params[:id])
		@projects=Project.find(:all)
		render :partial=>'projects',:locals=>{:projects=>@projects}
  end
end
