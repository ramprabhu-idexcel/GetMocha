require "#{Rails.root}/lib/ruby_classes_extensions"


#require "#{RAILS_ROOT}/lib/xmpp_message_extension"
APP_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/settings.yml")[RAILS_ENV].recursive_symbolize_keys!
