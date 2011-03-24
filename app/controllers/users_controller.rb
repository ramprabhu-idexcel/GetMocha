class UsersController <  Devise::RegistrationsController  
  before_filter :authenticate_user!,:except=>["new","create"]
  before_filter :session_clear
  def create
    build_resource
    if resource.save
      set_flash_message :notice, :signed_up
      @invite=Invitation.find(:all, :conditions=>['invitation_code is NULL AND status=? AND email=?', false, resource.email])
			if @invite 
        @invite.each do |invite|
          @project_user=ProjectUser.new(:project_id=>@invite.project_id, :user_id=>resource.id, :status=>true)
          @project_user.save
          @invite.update_attributes(:status=>true)
        end
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
      #~ render_with_scope :new
    end
  end
  
  def session_clear
    session[:project_name]=nil
  end
  
  
end
