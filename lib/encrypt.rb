require 'digest/sha1'
class Encrypt
  class<<self
    def verification_code
      Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    def default_password
      ActiveSupport::SecureRandom.base64(6)
    end
  end
end