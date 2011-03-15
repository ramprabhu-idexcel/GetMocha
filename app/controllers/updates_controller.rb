class UpdatesController < ApplicationController
	   before_filter :authenticate_user!

	def edit_profile
		puts "------------------"
		puts params.inspect
		puts current_user.inspect
		
		
	 end	
end
