unless (app_name = ENV["HEROKU_APP_NAME"]).nil?

  heroku        = PlatformAPI.connect_oauth(ENV["HEROKU_API_OAUTH_TOKEN"])
  last_release  = heroku.release.list(app_name)[-1]

  ENV["HEROKU_RELEASE_VERSION"]   = last_release["version"]
  ENV["HEROKU_RELEASE_DATE_ISO"]  = last_release["created_at"]
  ENV["HEROKU_RELEASE_DATE"]      = last_release["created_at"].to_datetime
                                                              .in_time_zone
                                                              .to_s(:short)
end
