class UpdatesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	before_filter :authenticate_user!

	def edit_profile
	 @user=current_user
   puts params[:user].inspect
	 value=params[:user].values[0]
    if @user.update_attributes(params[:user])	
      render :json=>{"success"=>value}.to_json
		else
       render :json=>{"error"=>@user.errors}.to_json
    end	
  end	
 
  def edit_password
    password=params[:password]
    confirm=params[:confirm]
    current_user.password=password.to_i
     current_user.password_confirmation=confirm.to_i
     if (current_user.password==current_user.password_confirmation)
          current_user.save
     end        
   	end 
  
  def contacts
		@fullname=[]
		@users=User.find(:all)
		@users.each do |i|
      @fullname << i.first_name + i.last_name
		end
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
  
  def delete_email
   secondary_email=SecondaryEmail.find_by_id(params[:id])
   secondary_email.delete if secondary_email
   render :nothing=>true
 end
 
 def save_image
   puts "------------------------"
   puts params.inspect
   puts "********"
   puts params["undefined"].inspect
   @attach=Attachment.new(:uploaded_data=>params["undefined"])
   @attach.attachable=current_user
   @attach.save
   @a=Attachment.find(:last)
   puts @a.public_filename
   render :json=>{:file_name=> @a.public_filename}.to_json

   
   #~ respond_to do |format|
      #~ if @a
         #~ puts "**************************"
        #~ flash[:notice] = 'Person was successfully created.'
        #~ format.xml { render :xml=>@a.public_filename,:status=>:created,:location=>"edit"}
        
         #~ format.json  { render :json => @a.public_filename, :status => :created, :location => "edit" }
      #~ end
       #~ end 
       
     end  
 
end					
					