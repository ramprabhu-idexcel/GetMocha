class AttachmentsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def new
		
	end
	
	def create
		session[:attaches_id] ||= ""
		@attachment=Attachment.new(:uploaded_data => params["undefined"])
		@attachment.save
		p @attachment.id
		session[:attaches_id] +="#{@attachment.id},"
		@attachments=Attachment.first
		#~ render :nothing=>true
		render :json=>{:file=>@attachment.filename, :id=>@attachment.id}.to_json
	end
	
end
