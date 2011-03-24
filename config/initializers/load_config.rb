require "#{Rails.root}/lib/ruby_classes_extensions"


#require "#{RAILS_ROOT}/lib/xmpp_message_extension"
APP_CONFIG = YAML.load_file("#{Rails.root}/config/settings.yml")[RAILS_ENV].recursive_symbolize_keys!
S3_CONFIG = YAML.load_file("#{Rails.root}/config/amazon_s3.yml")[RAILS_ENV].recursive_symbolize_keys!
