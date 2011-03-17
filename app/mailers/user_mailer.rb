class UserMailer < ActionMailer::Base
  default :from => "mochabot@getmocha.com"
   def verify_secondary_email(email,code)
    @url=verify_secondary_email_url(:verification_code=>code)
    mail(:to=>email, :subject=>"Verify Your Email Address on Mocha")
    @content_type="text/html"
   end
   # Method added for postfix functionality
   def receive(email)
    logger.info "*************************"
    logger.info email.inspect
    logger.info "*************************"
    end
end
