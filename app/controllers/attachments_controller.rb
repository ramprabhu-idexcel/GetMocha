#require 'home/kiruba/Desktop/GetMocha/vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb'
class AttachmentsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def new
	end
  def create
		session[:attaches_id] ||= []
		@attachment=Attachment.new(:uploaded_data => params["undefined"])
		@attachment.save
		session[:attaches_id] << @attachment.id
		#@attachment.after_process_attachment
		#~ render :nothing=>true
		render :json=>{:file=>@attachment.filename, :id=>@attachment.id}.to_json
	end
	def remove_attach
	@attach=Attachment.delete(params[:id])
	 Attachment.delete(params[:id].to_i)
	render :json=>params[:id].to_json
	end
end