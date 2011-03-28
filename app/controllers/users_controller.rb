class UsersController <  Devise::RegistrationsController
  before_filter :authenticate_user!,:except=>["new","create"]
  before_filter :session_clear
  def create
    resource=User.new(params[:user])
    user=User.find_by_email_and_is_guest(params[:user][:email],true)
    if user
      resource=user
      params[:user][:is_guest]=false
      resource.attributes=params[:user]
      end
    if resource.save
      resource.send_confirmation_instructions if user
      set_flash_message :notice, :signed_up
      invitations=Invitation.resource_email
      invitations.each do |invite|
        ProjectUser.create(:project_id=>invite.project_id, :user_id=>resource.id, :status=>true)
        invite.update_attributes(:status=>true)
      end
      render :udpate do |page|
        page.alert('Activation link has been sent to your account')
        page.redirect_to '/signin'
      end
    else
      errors=[]
      resource.errors.each_full{|msg| errors<< msg }
      clean_up_passwords(resource)
      render :udpate do |page|
        page.alert errors.join("\n")
      end
    end
  end
  def session_clear
    session[:project_name]=nil
  end
end