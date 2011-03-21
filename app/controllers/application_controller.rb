class ApplicationController < ActionController::Base
skip_before_filter :verify_authenticity_token
  #~ protect_from_forgery  layout :change_layout
  before_filter :find_project
  
  def change_layout
    if devise_controller?
      %w{edit}.include?(action_name) ? "application" : "before_login"
    else
      "application"
    end
  end
  
  def find_project
    @project=Project.find_by_id(params[:project_id]) if params[:project_id]
    session[:project_name]=@project.name if @project
  end
  
   
  
end
