class SessionsController <  Devise::SessionsController
	
  include Devise::Controllers::InternalHelpers
	
	 #~ def new
    #~ clean_up_passwords(build_resource)
    #~ render_with_scope :new
  #~ end
	
	def create
    resource = warden.authenticate!(:scope => resource_name)
    render :udpate do |page|
      page.redirect_to '/projects/new'
    end
  end
		
end
