class ApplicationController < ActionController::Base
skip_before_filter :verify_authenticity_token
#~ protect_from_forgery layout :change_layout
before_filter :http_authenticate, :except=>['message_create_via_email','check_from_address_email']
before_filter :check_from_address_email,:only=>['new_project_via_email','message_create_via_email','reply_to_message_via_email']
before_filter :find_project

layout :change_layout
  def change_layout
    if devise_controller?
      if (controller_name=="confirmations" || controller_name=="admin_confirmations")
           %w{show}.include?(action_name) ? "before_login" : "application"
      elsif controller_name=="registrations"
         %w{edit}.include?(action_name) ? false : "before_login"
      elsif controller_name=="sessions" || controller_name=="admin_sessions"
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
    session[:project_selected]=@project.id if @project
  end
  

    def remove_timestamps
    Activity.record_timestamps=false
  end
  def set_timestamps
    Activity.record_timestamps=true
  end
  protected
  def http_authenticate
    authenticate_or_request_with_http_basic do |user_name, password|
if RAILS_ENV=="staging"
user_name == "railsfactory" && password == "mocha"
else
      user_name == "getmocha" && password == "m0cha345"
end
    end
    warden.custom_failure! if performed?
 end
#~ def from_email_id
#~ @from_address=(params[:from].to_s)
  #~ end
end