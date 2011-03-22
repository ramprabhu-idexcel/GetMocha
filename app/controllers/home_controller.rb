class HomeController < ApplicationController
layout "before_login"
def index
	redirect_to '/messages' if current_user
end	

end
