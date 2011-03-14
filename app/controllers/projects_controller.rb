class ProjectsController < ApplicationController
	layout "application"
	
	def new
	end
	
	def create
		puts "Create"
		puts params.inspect
	end
end
