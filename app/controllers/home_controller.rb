class HomeController < ApplicationController
layout "before_login"
	protect_from_forgery  :except=>:check_email_reply_and_save
def index
	redirect_to '/messages' if current_user
end	

def check_email_reply_and_save
	
end

end
