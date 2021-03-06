GetMocha::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files
  # See everything in the log (default is :info)
  # config.log_level = :debug
  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new
  # Use a different cache store in production
  # config.cache_store = :mem_cache_store
  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false
  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"
  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  # Enable threaded mode
  # config.threadsafe!
  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true
  #~ config.action_controller.asset_host = "https://mocha-asset%d.s3.amazonaws.com"
  #~ config.action_controller.asset_host = "http://asset%d.getmocha.com"
  ActionController::Base.asset_host = Proc.new { |source|
    "http://asset#{source.hash % 2 + 1 }.getmocha.com"
  }

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  config.action_mailer.default_url_options = { :host => 'getmocha.com' }
  config.middleware.use ExceptionNotifier,
  :email_prefix => "[Exception] ",
  :sender_address => %{"Exception Notifier" <admin@getmocha.com>},
  :exception_recipients => %w{priya@railsfactory.org senthilkumar@sedin.co.in c.selvakumar@sedin.co.in kirubakaran@sedin.co.in ramprabu.n@railsbuddies.com}
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "smtp.sendgrid.net",
  :port => '25',
  :domain => "reply.getmocha.com",
  :authentication => :plain,
  :user_name => "jesse@catalystfactory.com",
  :password => "railsfactory"
  }
end