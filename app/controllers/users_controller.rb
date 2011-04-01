class UsersController <  Devise::RegistrationsController
  before_filter :authenticate_user!,:except=>["new","create"]
  before_filter :session_clear
  def create
    resource=User.new(params[:user])
          resource.time_zone="(GMT+10:00) Eastern Time - Brisbane"
    user=User.find_by_email_and_is_guest(params[:user][:email],true)
    if user
      resource=user
      params[:user][:is_guest]=false
      resource.attributes=params[:user]
      end
    if resource.save
      resource.send_confirmation_instructions if user
      set_flash_message :notice, :signed_up
      invitations=Invitation.resource_email(resource)
      invitations.each do |invite|
        proj_user=ProjectUser.find_by_project_id_and_user_id(invite.project_id, resource.id)
        if !proj_user
          ProjectUser.create(:project_id=>invite.project_id, :user_id=>resource.id, :status=>true)
        end
        invite.update_attributes(:status=>true)
      end
      render :udpate do |page|
        page.alert('Activation link has been sent to your account')
        page.redirect_to '/signin'
      end
    else
      errors=[]
      resource.errors.each_full{|msg| errors<< msg }
      errors=errors.uniq
      clean_up_passwords(resource)
      render :udpate do |page|
        page.alert errors.join("\n")
      end
    end
  end
  def session_clear
    session[:project_name]=nil
    session[:project_selected]=nil
  end
end