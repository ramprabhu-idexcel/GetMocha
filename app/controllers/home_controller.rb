class HomeController < ApplicationController
layout "before_login"
  skip_before_filter :http_authenticate,:only=>['check_email_reply_and_save','privacy']
	protect_from_forgery  :except=>:check_email_reply_and_save
def index
	redirect_to '/messages' if current_user
end	

def check_email_reply_and_save
		
			logger.info "**********************************************"
		
		
		html_content=params[:html]
		 santized_html=Sanitize.clean(html)
		logger.info santized_html.inspect
		
		logger.info "**********************************************"
	  render :text => "success"
end

end
