class UsersController <  Devise::RegistrationsController  
  before_filter :authenticate_user!,:except=>["new","create"]
  def create
    build_resource
    if resource.save
      set_flash_message :notice, :signed_up
      render :udpate do |page|
        page.redirect_to '/projects/new'
      end
      
    else
      errors=[]
      resource.errors.each_full{|msg| errors<< msg } 
      clean_up_passwords(resource)
      render :udpate do |page|
        page.alert errors.join("\n")
      end
      #~ render_with_scope :new
    end
  end
  
  
end
