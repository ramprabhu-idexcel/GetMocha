#require 'home/kiruba/Desktop/GetMocha/vendor/plugins/attachment_fu/lib/technoweenie/attachment_fu.rb'
class AttachmentsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	def new
	end
  def create
		if params[:undefined]
			session[:attaches_id] ||= []
      attachment=Attachment.new(:uploaded_data => params["undefined"])
      attachment.save
      session[:attaches_id] << attachment.id	
      render :json=>attachment.display_data.to_json
    else
			render :json=>{:none=>"nothing"}.to_json
    end
	end
	def remove_attach
	@attach=Attachment.delete(params[:id])
	 Attachment.delete(params[:id].to_i)
	render :json=>params[:id].to_json
	end
end