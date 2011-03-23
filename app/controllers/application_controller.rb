class ApplicationController < ActionController::Base
skip_before_filter :verify_authenticity_token
  #~ protect_from_forgery  layout :change_layout
  before_filter :http_authenticate
  before_filter :find_project
  layout :change_layout
  
  def change_layout

    if devise_controller?
           
       if (controller_name=="confirmations")
         %w{show}.include?(action_name) ? "before_login" : "application"
       end  
       
       if ((controller_name=="registrations") || (controller_name=="sessions"))
       %w{edit}.include?(action_name) ? "application" : "before_login"
       else
        %w{edit}.include?(action_name) ? "before_login" : "application"
       end
     
     elsif controller_name=="home"
        "before_login"
     else
      "application"
     end
  end
  
  def find_project
    @project=Project.find_by_id(params[:project_id]) if params[:project_id]
    session[:project_name]=@project.name if @project
  end
  
 
  protected

  def http_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
      user_name == "getmocha" && password == "m0cha345"
    end
    warden.custom_failure! if performed?
  end

  
   
  
end
