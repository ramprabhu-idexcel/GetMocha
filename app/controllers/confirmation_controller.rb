class ConfirmationController < Devise::ConfirmationsController
	def show
		self.resource = resource_class.confirm_by_token(params[:confirmation_token])
		if resource.errors.empty?
			
      set_flash_message :notice, :confirmed
			redirect_to   "/signin"
    else
      redirect_to   "/signin"
		end
	end
end