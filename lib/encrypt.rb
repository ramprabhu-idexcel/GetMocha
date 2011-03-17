require 'digest/sha1'
class Encrypt
  def self.verification_code
    Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end