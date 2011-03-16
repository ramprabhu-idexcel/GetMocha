class UpdatesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

	def edit_profile
	 @user=current_user
    if @user.update_attributes(params[:user]) then		
             render :nothing=>true
		else
			    render :update do |page|
					 	page.alert(@user.errors)
					end	
	end	
 end	

 
 
 def edit_password
	 
	 current_user.password=params[:password]
	 current_user.password_confirmation=params[:password]
	 current_user.save
	end 

def contacts
			puts "********"
		@fullname=[]
		@users=User.find(:all)
		@users.each do |i|
		@fullname << i.first_name + i.last_name
		end
		puts @fullname.inspect
		
		 for i in 0..@users.length-1
			  puts @fullname[i]
			
					  end
					end
end					
					