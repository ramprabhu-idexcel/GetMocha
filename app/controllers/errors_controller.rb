class ErrorsController < ApplicationController
  layout "application", :except => ['routing']
	def routing
	puts "---------------"
  #~ render :file => "#{Rails.root}/public/404.html", :status => 404, :layout =>true
 end
 
 
end

