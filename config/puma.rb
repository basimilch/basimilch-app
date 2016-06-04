# This config file gets loaded when starting Puma as the web server in Heroku as
# configured in the 'Procfile' at the app's root folder.
# SOURCE: https://www.railstutorial.org/book/_single-page#sec-production_webserver
# SOURCE: https://devcenter.heroku.com/articles/ruby-default-web-server
# SOURCE: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#config
# SOURCE: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#procfile

workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # DOC: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection
end