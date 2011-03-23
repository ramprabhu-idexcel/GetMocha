class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save']
	protect_from_forgery  :except=>:check_email_reply_and_save
def index
	redirect_to '/messages' if current_user
end	

def check_email_reply_and_save
			logger.info("IN check_email_reply_and_save")
			logger.info "**********************************************"
			logger.info params.inspect
			logger.info "**********************************************"
		logger.info(params[:html])
		logger.info "**********************************************"
		logger.info(params[:to])
		logger.info "**********************************************"
	  render :text => "success"
end

end
