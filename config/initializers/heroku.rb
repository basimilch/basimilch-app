unless (app_name = ENV["HEROKU_APP_NAME"]).nil?

  # Reminder about how to manage authorization tokens for the Heroku API:
  #
  # List authorization tokens:
  #   $ heroku authorizations
  #
  # Create a new authorization token:
  #   $ heroku authorizations:create \
  #            --description "For use within the my.basimilch Rails app" \
  #            --scope identity,read-protected
  #
  # Setup the necessary ENV variablables in Heroku:
  #   $ heroku config:add \
  #            HEROKU_APP_NAME=<heroku-app-name> \
  #            HEROKU_API_OAUTH_ID=<heroku-api-oauth-id> \
  #            HEROKU_API_OAUTH_TOKEN=<heroku-api-oauth-token>
  #
  # NOTE: Do not commit any secrets in the code because it's public!
  #       Use EVN variables instead!
  #
  # Relevant sources:
  #  - https://github.com/heroku/heroku-oauth#creating
  #  - https://github.com/heroku/platform-api#a-real-world-example
  #  - http://stackoverflow.com/a/15367505

  heroku            = PlatformAPI.connect_oauth(ENV["HEROKU_API_OAUTH_TOKEN"])
  release_list      = heroku.release.list(app_name)

  last_release        = release_list[-1] || {}
  released_slug       = {}
  if released_slug_id = last_release.get('slug', 'id')
    released_slug     = heroku.slug.info(app_name,released_slug_id)
  end

  previous_release    = release_list[-2] || {}
  previous_slug       = {}
  if previous_slug_id = previous_release.get('slug', 'id')
    previous_slug     = heroku.slug.info(app_name,previous_slug_id)
  end

  ENV["HEROKU_RELEASE_VERSION"]   = last_release['version'].to_s
  ENV["HEROKU_RELEASE_DATE_ISO"]  = last_release['created_at'].to_s
  ENV["HEROKU_RELEASE_DATE"]      = last_release['created_at'].to_datetime
                                                              .in_time_zone
                                                              .to_s(:short)
  ENV["HEROKU_RELEASE_COMMIT"]      = released_slug['commit'].to_s
  ENV["HEROKU_RELEASE_COMMIT_MSGS"] = released_slug['commit_description'].to_s
  ENV["HEROKU_RELEASE_PREVIOUS_COMMIT"] = previous_slug['commit'].to_s
end
