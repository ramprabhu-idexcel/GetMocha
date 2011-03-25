class PasswordsController < Devise::PasswordsController
  layout "before_login"
  prepend_before_filter :require_no_authentication
  include Devise::Controllers::InternalHelpers
  # PUT /resource/password
  def update
   self.resource = resource_class.reset_password_by_token(params[:user])
      
    if resource.errors.empty?
      set_flash_message :notice, :updated
      sign_in_and_redirect(resource_name, resource)
    else
      errors=[]
      resource.errors.each_full{|msg| errors<< msg } 
      render :json=>{:failure=>errors.join("\n")}.to_json
    end 
			  
    end   
end
