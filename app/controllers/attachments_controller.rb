class AttachmentsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def new
		
	end
	
	def create
		session[:attaches_id] ||= []
		@attachment=Attachment.new(:uploaded_data => params["undefined"])
		@attachment.save
		p	session[:attaches_id] << @attachment.id
			#~ render :nothing=>true
		render :json=>{:file=>@attachment.filename, :id=>@attachment.id}.to_json
	end
	def remove_attach
	@attach=Attachment.delete(params[:id])
	 session[:attaches_id].delete(params[:id].to_i)
	render :json=>params[:id].to_json
	end
	
	
end
