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
		p session[:attaches_id]
		#~ render :nothing=>true
		render :json=>{:file=>@attachment.filename, :id=>@attachment.id}.to_json
	end
	def remove_attach
		p session[:attaches_id] ||= ""
		p params[:id]
		@attach=Attachment.delete(params[:id])
	p	session[:attaches_id].split(',')
		p session[:attaches_id].split(',').delete('params[:id]')
		p session[:attachess_id]
		p"============="
		render :nothing=>true
	#	render :json=>{:file=>@attachment.filename, :id=>@attachment.id}.to_json
	end
	
	
end
