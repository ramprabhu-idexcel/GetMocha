class SessionsController <  Devise::SessionsController
  include Devise::Controllers::InternalHelpers
	 #~ def new
    #~ clean_up_passwords(build_resource)
    #~ render_with_scope :new
  #~ end
	def create
    session[:project_name]=nil
		session[:project_selected]=nil
    resource = warden.authenticate!(:scope => resource_name)
    if resource
      invitations=Invitation.resource_email(resource)
      invitations.each do |invite|
        proj_user=ProjectUser.find_by_project_id_and_user_id(invite.project_id, resource.id)
        if !proj_user
          ProjectUser.create(:project_id=>invite.project_id, :user_id=>resource.id, :status=>true)
        end
        invite.update_attributes(:status=>true)	
     end
    end	
    if session[:chat_invite]
      render :json=>{:url=>session[:chat_invite]}
    else
      render :json=>{:url=>messages_path}
    end
  end
end
