class UpdatesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	   before_filter :authenticate_user!

	def edit_profile
		puts "------------------"
		puts params[:user][:first_name]
	   puts "----------------" 
   
    @user=current_user
    if @user.update_attributes(params[:user]) then		
         	puts @user.first_name
		      render :partial=>'edit1'
		else
			    render :update do |page|
						page.alert(@user.errors)
					end	
	end	
	 end	
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