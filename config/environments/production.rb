Rails.application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like
  # NGINX, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Enable serving static files from the `/public` folder since Apache or NGINX
  # are not used in Heroku.
  # DOC: https://devcenter.heroku.com/articles/rails-4-asset-pipeline#serve-assets
  # NOTE: This setting is also done by the gem 'rails_12factor', but setting
  #       this here again to avoid confusion.
  config.serve_static_files = true

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Asset digests allow you to set far-future HTTP expiration dates on
  # all assets, yet still be able to expire them through the digest
  # params.
  config.assets.digest = true

  # `config.assets.precompile` and `config.assets.version` have moved
  # to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Mount Action Cable outside main process or domain
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]

  # Force all access to the app over SSL, use Strict-Transport-
  # Security, and use secure cookies.
  # For custom domain, SSL has to be configured on Heroku.
  # Sources:
  #   https://devcenter.heroku.com/articles/ssl-endpoint
  #   https://www.railstutorial.org/book/_single-page#sec-ssl_in_production
  config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # DOC: http://guides.rubyonrails.org/v5.2.1/configuring.html
  # DOC: https://devcenter.heroku.com/articles/http-request-id
  config.log_tags = [ :host, :subdomain, :remote_ip, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an
  # asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  config.action_mailer.default charset: 'utf-8'
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  if ENV['HEROKU_APP_NAME'] == "basimilch"
    host = "meine.basimil.ch"
  else
    host = "#{ENV['HEROKU_APP_NAME']}.herokuapp.com"
  end
  config.action_mailer.default_url_options = { host: host }
  # DOC: http://api.rubyonrails.org/classes/ActionMailer/Base.html
  config.action_mailer.smtp_settings = {
    address:              ENV['EMAIL_SMTP_ADDRESS'],
    port:                 ENV['EMAIL_SMTP_PORT'],
    authentication:       :login,
    user_name:            ENV['EMAIL_SMTP_USERNAME'],
    password:             ENV['EMAIL_SMTP_PASSWORD'],
    domain:               ENV['EMAIL_SMTP_DOMAIN'],
    # For email SMTP configuration with SSL/TLS (encrypted) tls: must be given.
    # SOURCE: http://stackoverflow.com/questions/26166032/rails-4-netreadtimeout-when-calling-actionmailer
    tls:                  true,
    enable_starttls_auto: true
  }

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "basimilch_app_#{Rails.env}"

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end


  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false
end
