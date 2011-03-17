class UpdatesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

	def edit_profile
	 @user=current_user
   puts params[:user].inspect
    if @user.update_attributes(params[:user])	
      render :nothing=>true
		else
      render :update do |page|
        page.alert(@user.errors)
      end	
    end	
  end	
 
  def edit_password
    current_user.password=params[:password]
    current_user.password_confirmation=params[:password]
    current_user.save
	end 
  
  def contacts
		@fullname=[]
		@users=User.find(:all)
		@users.each do |i|
      @fullname << i.first_name + i.last_name
		end
		
		 #~ for i in 0..@users.length-1
			
					  #~ end
  end
          
  def create_secondary_email
    @secondary_email=current_user.secondary_emails.build(:email=>params[:secondary_email])
    if @secondary_email.valid?
      @secondary_email.save
      render :partial=>"field"
    else
      render :json=>{"error"=>@secondary_email.errors.entries.first.join(' ')}.to_json
    end
  end
  
  def verify_email
    s=SecondaryEmail.find_by_confirmation_token(params[:verification_code])
    s.udpdate_attribute(:confirmation_token,nil) if s
    redirect_to '/sign_in'      
  end
end					
					