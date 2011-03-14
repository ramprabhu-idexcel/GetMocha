class ProjectsController < ApplicationController
	#~ before_filter :authenticate_user!
	layout "application"

	
	def new
	end
	
	def create
		puts "Create"
		puts params.inspect
	end
end
