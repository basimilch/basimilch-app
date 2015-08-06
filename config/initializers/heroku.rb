unless (app_name = ENV["HEROKU_APP_NAME"]).nil?

  # Relevant sources:
  #  - https://github.com/heroku/heroku-oauth#creating
  #  - https://github.com/heroku/platform-api#a-real-world-example
  #  - http://stackoverflow.com/a/15367505

  heroku        = PlatformAPI.connect_oauth(ENV["HEROKU_API_OAUTH_TOKEN"])
  last_release  = heroku.release.list(app_name)[-1]

  ENV["HEROKU_RELEASE_VERSION"]   = last_release["version"].to_s
  ENV["HEROKU_RELEASE_DATE_ISO"]  = last_release["created_at"].to_s
  ENV["HEROKU_RELEASE_DATE"]      = last_release["created_at"].to_datetime
                                                              .in_time_zone
                                                              .to_s(:short)
end
