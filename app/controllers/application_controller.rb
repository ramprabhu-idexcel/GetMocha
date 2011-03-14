class ApplicationController < ActionController::Base
  protect_from_forgery
  layout :change_layout
  
  def change_layout
    if devise_controller?
      "before_login"
    else
      "application"
    end
  end
end
