class SessionsController <  Devise::SessionsController
	
  include Devise::Controllers::InternalHelpers
	
	 #~ def new
    #~ clean_up_passwords(build_resource)
    #~ render_with_scope :new
  #~ end
	
	def create
		puts "^^^^^^^^^^^^^^^"
		puts resource_name
		
    resource = warden.authenticate!(:scope => resource_name, :recall => "new")
		puts "---------------------"
		puts resource.inspect
		
    set_flash_message :notice, :signed_in
     render :udpate do |page|
        page.redirect_to '/projects/new'
      end
		end
		
end
