require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BasimilchApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Bern'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.fallbacks       = [:en]
    config.i18n.default_locale  = 'de-CH'

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.after_initialize do
      # Run directly after the initialization of the application,
      # after the application initializers in config/initializers are
      # run.
      # Source:
      #   http://guides.rubyonrails.org/configuring.html#initialization-events
      if Rails.env.production?
        config.x.heroku.release =
          {
            version:     ENV["HEROKU_RELEASE_VERSION"],
            date_iso:    ENV["HEROKU_RELEASE_DATE_ISO"],
            date:        ENV["HEROKU_RELEASE_DATE"],
            commit:      ENV["HEROKU_RELEASE_COMMIT"],
            commit_msg:  ENV["HEROKU_RELEASE_COMMIT_MSG"],
            prev_commit: ENV["HEROKU_RELEASE_PREVIOUS_COMMIT"]
          }
      else
        config.x.heroku.release =
          {
            version:     "Dev",
            date_iso:    Time.now.to_s,
            date:        Time.now.to_s(:short),
            commit:      "bbbbbbbbbbbbbb",
            commit_msg:  "Still working on the next commit...",
            prev_commit: "aaaaaaaaaaaaaa"
          }
      end
    end
  end
end
