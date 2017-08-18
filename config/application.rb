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

    # This will route any exceptions caught to your router Rack app.
    # DOC: https://wearestac.com/blog/dynamic-error-pages-in-rails
    config.exceptions_app = self.routes

    # Run directly after the initialization of the application,
    # after the application initializers in config/initializers are
    # run.
    # Source:
    #   http://guides.rubyonrails.org/configuring.html#initialization-events
    config.after_initialize do

      # Basimilch global defaults
      config.x.defaults.user_postal_code  = "8000"
      config.x.defaults.user_city         = I18n.t :zurich
      config.x.defaults.user_country      = I18n.t :switzerland

      github_repo_base_url = "https://github.com/basimilch/basimilch-app"
      if Rails.env.production?
        config.x.release =
          {
            version:     ENV["HEROKU_RELEASE_VERSION"],
            version_url: github_repo_base_url + "/tree/" +
                         ENV["HEROKU_RELEASE_COMMIT"],
            date_iso:    ENV["HEROKU_RELEASE_DATE_ISO"],
            date:        ENV["HEROKU_RELEASE_DATE"],
            commit:      ENV["HEROKU_RELEASE_COMMIT"],
            commit_url:  github_repo_base_url + "/commit/" +
                         ENV["HEROKU_RELEASE_COMMIT"],
            commit_msgs: ENV["HEROKU_RELEASE_COMMIT_MSGS"],
            prev_commit: ENV["HEROKU_RELEASE_PREVIOUS_COMMIT"],
            diff_url:    github_repo_base_url + "/compare/" +
                         ENV["HEROKU_RELEASE_PREVIOUS_COMMIT"] + "..." +
                         ENV["HEROKU_RELEASE_COMMIT"]
          }
      else
        config.x.release =
          {
            version:     "Dev",
            version_url: github_repo_base_url + "/tree/" + "bbbbbbbbbbbbbb",
            date_iso:    Time.now.to_s,
            date:        Time.now.to_s(:short),
            commit:      "bbbbbbbbbbbbbb",
            commit_url:  github_repo_base_url + "/commit/" + "bbbbbbbbbbbbbb",
            commit_msgs: "  * author: last commit message\n" +
                         "  * author: before last commit message",
            prev_commit: "aaaaaaaaaaaaaa",
            diff_url:    github_repo_base_url + "/compare/" +
                         "aaaaaaaaaaaaaa...bbbbbbbbbbbbbb"
          }
      end
    end
  end
end
