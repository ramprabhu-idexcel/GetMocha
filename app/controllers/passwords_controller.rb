class PasswordsController < Devise::PasswordsController
  layout "before_login"
  prepend_before_filter :require_no_authentication
  include Devise::Controllers::InternalHelpers
  # PUT /resource/password
   def create
         errors=[]
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions
      redirect_to new_session_path(resource_name)
    else
      puts resource.errors
      resource.errors.each_full{|msg| errors<<msg }
      render :json=>{:failure=>errors.join("\n")}.to_json
    end
  end
  def edit
    self.resource = resource_class.new
    a=User.find_by_reset_password_token(params[:reset_password_token])
    resource.reset_password_token = params[:reset_password_token]
    if !a
      redirect_to '/signin'
    else
      render_with_scope :edit
    end
  end
  def update
   self.resource = resource_class.reset_password_by_token(params[:user])
     if resource.errors.empty?
      set_flash_message :notice, :updated
      sign_in_and_redirect(resource_name, resource)
    else
      resource.errors.each_full{|msg| errors<< msg }
      render :json=>{:failure=>errors.join("\n")}.to_json
    end
    end
   end