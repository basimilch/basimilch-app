# Gemfile from http://sample-app-gemfile.railstutorial.org
# Use 'bundle install' on the command line to install all this gems.
# Info about Gemfile.lock and why to commit:
# http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source 'https://rubygems.org'

# NOTE: After updating ruby, you have to install it and all the gems again:
#         $ rvm install 2.4.1 && gem install bundle && bundle install
#       The first and last commands might take long to execute (ca. 5 min).
ruby '2.4.1'
# https://github.com/ruby/ruby/tree/v2_4_1
# https://www.ruby-lang.org/en/news/2015/12/25/ruby-2-3-0-released/
# https://www.ruby-lang.org/en/news/2016/04/26/ruby-2-3-1-released/
# https://www.ruby-lang.org/en/news/2017/03/22/ruby-2-4-1-released/
# https://github.com/ruby/ruby/blob/v2_4_1/NEWS

# NOTE: Use use fixed gem versions instead of ruby's pessimistic version
#       constraint operator (~>) to manually control the updates (and calling
#       'bundle update' by mistake) and to maintain the proper url abouth the
#       gem. To know which gems to update we can run 'bundle outdated' and
#       update the versions in this Gemfile accordingly.
#       More info and references: https://stackoverflow.com/q/9265213

# DOC: http://guides.rubyonrails.org/v5.1.3/upgrading_ruby_on_rails.html
gem 'rails',                    '5.1.3'   # https://rubygems.org/gems/rails/versions/5.1.3
                                          # https://github.com/rails/rails/tree/v5.1.3
                                          # https://github.com/rails/rails/compare/v4.2.5.2...v4.2.6
                                          # https://github.com/rails/rails/compare/v4.2.6...v4.2.9
                                          # https://github.com/rails/rails/compare/v4.2.9...v5.0.4
                                          # https://github.com/rails/rails/compare/v5.0.4...v5.1.3
                                          # https://github.com/rails/rails/releases
                                          # http://weblog.rubyonrails.org/releases/

# bcrypt() is a sophisticated and secure hash algorithm designed by The OpenBSD
# project for hashing passwords. The bcrypt Ruby gem provides a simple wrapper
# for safely handling passwords.
gem 'bcrypt',                   '3.1.11'  # https://rubygems.org/gems/bcrypt/versions/3.1.11
                                          # https://github.com/codahale/bcrypt-ruby
                                          # https://github.com/codahale/bcrypt-ruby/blob/master/CHANGELOG
                                          # https://github.com/codahale/bcrypt-ruby/releases

# Used to easily generate fake data: names, addresses, phone numbers, etc. (used
# for DB seeding)
gem 'faker',                    '1.8.4'   # https://rubygems.org/gems/faker/versions/1.8.4
                                          # https://github.com/stympy/faker/tree/v1.8.4
                                          # https://github.com/stympy/faker/releases

# Upload files in your Ruby applications, map them to a range of ORMs, store
# them on different backends.
gem 'carrierwave',              '1.1.0'   # https://rubygems.org/gems/carrierwave/versions/1.1.0
                                          # https://github.com/carrierwaveuploader/carrierwave/tree/v1.1.0
                                          # https://github.com/carrierwaveuploader/carrierwave/blob/master/CHANGELOG.md
                                          # https://github.com/carrierwaveuploader/carrierwave/releases

# Manipulate images with minimal use of memory via ImageMagick / GraphicsMagick
gem 'mini_magick',              '4.8.0'   # https://rubygems.org/gems/mini_magick/versions/4.8.0
                                          # https://github.com/minimagick/minimagick/tree/v4.8.0
                                          # https://github.com/minimagick/minimagick/releases

# The Ruby cloud services library. Supports all major cloud providers including
# AWS, Rackspace, Linode, Blue Box, StormOnDemand, and many others. Full support
# for most AWS services including EC2, S3, CloudWatch, SimpleDB, ELB, and RDS.
gem 'fog',                      '1.41.0'  # https://rubygems.org/gems/fog/versions/1.41.0
                                          # https://github.com/fog/fog/tree/v1.41.0
                                          # https://github.com/fog/fog/blob/master/CHANGELOG.md
                                          # https://github.com/fog/fog/releases

# will_paginate provides a simple API for performing paginated queries with
# Active Record, DataMapper and Sequel, and includes helpers for rendering
# pagination links in Rails, Sinatra and Merb web apps.
gem 'will_paginate',            '3.1.6'   # https://rubygems.org/gems/will_paginate/versions/3.1.6
                                          # https://github.com/mislav/will_paginate/tree/v3.1.6
                                          # https://github.com/mislav/will_paginate/releases

# Hooks into will_paginate to format the html to match Twitter Bootstrap
# styling.
gem 'bootstrap-will_paginate',  '1.0.0'   # https://rubygems.org/gems/bootstrap-will_paginate/versions/1.0.0
                                          # https://github.com/yrgoldteeth/bootstrap-will_paginate/tree/v1.0.0
                                          # https://github.com/yrgoldteeth/bootstrap-will_paginate/releases

# bootstrap-sass is a Sass-powered version of Bootstrap 3, ready to drop right
# into your Sass powered applications.
gem 'bootstrap-sass',           '3.3.7'   # https://rubygems.org/gems/bootstrap-sass/versions/3.3.7
                                          # https://github.com/twbs/bootstrap-sass/tree/v3.3.7
                                          # https://github.com/twbs/bootstrap-sass/blob/master/CHANGELOG.md
                                          # https://github.com/twbs/bootstrap-sass/releases

# Sass adapter for the Rails asset pipeline.
gem 'sass-rails',               '5.0.6'   # https://rubygems.org/gems/sass-rails/versions/5.0.6
                                          # https://github.com/rails/sass-rails/tree/v5.0.6
                                          # https://github.com/rails/sass-rails/releases

# Uglifier minifies JavaScript files by wrapping UglifyJS to be accessible in
# Ruby.
gem 'uglifier',                 '3.2.0'   # https://rubygems.org/gems/uglifier/versions/3.2.0
                                          # https://github.com/lautis/uglifier/tree/v3.2.0
                                          # https://github.com/lautis/uglifier/blob/master/CHANGELOG.md
                                          # https://github.com/lautis/uglifier/releases

# CoffeeScript adapter for the Rails asset pipeline.
gem 'coffee-rails',             '4.2.2'   # https://rubygems.org/gems/coffee-rails/versions/4.2.2
                                          # https://github.com/rails/coffee-rails/tree/v4.2.2
                                          # https://github.com/rails/coffee-rails/blob/master/CHANGELOG.md
                                          # https://github.com/rails/coffee-rails/releases

# Provides jQuery and the jQuery-ujs driver for the Rails 4+ application.
gem 'jquery-rails',             '4.3.1'   # https://rubygems.org/gems/jquery-rails/versions/4.3.1
                                          # https://github.com/rails/jquery-rails/releases
                                          # https://github.com/rails/jquery-rails/blob/master/CHANGELOG.md

# Rails engine for Turbolinks 5 support.
gem 'turbolinks',               '5.0.1'   # https://rubygems.org/gems/turbolinks/versions/5.0.1
                                          # https://github.com/turbolinks/turbolinks/releases

# Create JSON structures via a Builder-style DSL
gem 'jbuilder',                 '2.7.0'   # https://rubygems.org/gems/jbuilder/versions/2.7.0
                                          # https://github.com/rails/jbuilder/tree/v2.7.0
                                          # https://github.com/rails/jbuilder/blob/master/CHANGELOG.md
                                          # https://github.com/rails/jbuilder/releases

# Ruby HTTP client for the Heroku API.
gem 'platform-api',             '2.1.0'   # https://rubygems.org/gems/platform-api/versions/2.1.0
                                          # https://github.com/heroku/platform-api/releases

# A set of common locale data and translations to internationalize and/or
# localize your Rails applications.
gem 'rails-i18n',               '5.0.4'   # https://rubygems.org/gems/rails-i18n/versions/5.0.4
                                          # https://github.com/svenfuchs/rails-i18n/blob/master/CHANGELOG.md

# Adds useful methods to validate, display and save phone numbers.
gem 'phony_rails',              '0.14.6'  # https://rubygems.org/gems/phony_rails/versions/0.14.6
                                          # https://github.com/joost/phony_rails/tree/v0.14.6
                                          # https://github.com/joost/phony_rails/blob/master/CHANGELOG.md
                                          # https://github.com/joost/phony_rails/compare/v0.12.11...v0.14.2
                                          # https://github.com/joost/phony_rails/compare/v0.14.2...v0.14.6
                                          # https://github.com/joost/phony_rails/releases

# Provides object geocoding (by street or IP address), reverse geocoding
# (coordinates to street address), distance queries for ActiveRecord and
# Mongoid, result caching, and more.
gem 'geocoder',                 '1.4.4'   # https://rubygems.org/gems/geocoder/versions/1.4.4
                                          # https://github.com/alexreisner/geocoder/releases
                                          # https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md

# Track changes to your models' data. Good for auditing or versioning. (i.e.
# allows undo)
gem 'paper_trail',              '7.1.1'   # https://rubygems.org/gems/paper_trail/versions/7.1.1
                                          # https://github.com/airblade/paper_trail/tree/v7.1.1
                                          # https://github.com/airblade/paper_trail/blob/master/CHANGELOG.md
                                          # https://github.com/airblade/paper_trail/compare/v4.1.0...v5.1.1
                                          # https://github.com/airblade/paper_trail/compare/v5.1.1...v7.1.1
                                          # https://github.com/airblade/paper_trail/compare/v7.1.0...v7.1.1
                                          # https://github.com/airblade/paper_trail/blob/master/CHANGELOG.md

# Easy activity tracking for models - similar to Github's Public Activity. (i.e.
# allows timeline).
gem 'public_activity',          '1.5.0'   # https://rubygems.org/gems/public_activity/versions/1.5.0
                                          # https://github.com/chaps-io/public_activity/tree/v1.5.0
                                          # https://github.com/chaps-io/public_activity/blob/v1.5.0/CHANGELOG.md
                                          # https://github.com/chaps-io/public_activity/compare/v1.4.1...v1.5.0
                                          # https://github.com/chaps-io/public_activity/releases

# Gem which calculates the difference between two times and returns a hash with
# the difference in terms of year, month, week, day, hour, minute and second.
gem 'time_diff',                '0.3.0'   # https://rubygems.org/gems/time_diff/versions/0.3.0
                                          # https://github.com/abhidsm/time_diff/tree/v0.3.0

# pg is the Ruby interface to the PostgreSQL RDBMS.
gem 'pg',                       '0.21.0'  # https://rubygems.org/gems/pg/versions/0.21.0
                                          # https://bitbucket.org/ged/ruby-pg/src?at=v0.21.0

# New Relic provides you with deep information about the performance of your web
# application as it runs in production.
gem 'newrelic_rpm',             '4.3.0.335' # https://rubygems.org/gems/newrelic_rpm
                                            # https://github.com/newrelic/rpm

# A gem that provides a client interface for the Sentry error logger.
gem 'sentry-raven',             '2.6.3'   # https://rubygems.org/gems/sentry-raven
                                          # https://github.com/getsentry/raven-ruby

group :development, :test do

  # Dropping a `byebug` (or `debugger`) call anywhere in your code, you get a
  # debug prompt.
  gem 'byebug',                 '9.1.0'   # https://rubygems.org/gems/byebug
                                          # https://github.com/deivid-rodriguez/byebug/tree/v9.1.0
                                          # https://github.com/deivid-rodriguez/byebug/releases

  # Preloads the application so things like console, rake and tests run faster.
  gem 'spring',                 '2.0.2'   # https://rubygems.org/gems/spring/versions/2.0.2
                                          # https://github.com/rails/spring/tree/v2.0.2
                                          # https://github.com/rails/spring/blob/master/CHANGELOG.md
                                          # https://github.com/rails/spring/compare/v1.6.4...v1.7.1
                                          # https://github.com/rails/spring/compare/v1.7.1...v2.0.2
                                          # https://github.com/rails/spring/releases

  # Autoload `dotenv` in Rails, which in its turn loads environment variables
  # from `.env` files.
  # Alternative: https://github.com/laserlemon/figaro#is-figaro-like-dotenv
  gem 'dotenv-rails',           '2.2.1'   # https://rubygems.org/gems/dotenv-rails/versions/2.2.1
                                          # https://github.com/bkeepers/dotenv/tree/v2.2.1
                                          # https://github.com/bkeepers/dotenv/releases
                                          # https://github.com/bkeepers/dotenv/blob/master/Changelog.md

  # Guard is a command line tool to easily handle events on file system
  # modifications.
  gem 'guard',                  '2.14.1'  # https://rubygems.org/gems/guard/versions/2.14.1
                                          # https://github.com/guard/guard/tree/v2.14.1
                                          # https://github.com/guard/guard/releases

end

group :development do

  # A debugging tool for your Ruby on Rails applications. Dropping a `console`
  # call in a controller or view, you get a ruby console in the browser.
  gem 'web-console',            '3.5.1'   # https://rubygems.org/gems/web-console/versions/3.5.1
                                          # https://github.com/rails/web-console/releases

  # FIXME: Does not work from within tmux.
  # DOC: https://github.com/Codaisseur/terminal-notifier-guard#caveats
  # gem 'terminal-notifier-guard','1.7.0' # https://github.com/Codaisseur/terminal-notifier-guard/releases

  # Profiling toolkit for Rack applications with Rails integration. Client Side
  # profiling, DB profiling and Server profiling.
  gem 'rack-mini-profiler',     '0.10.5'  # https://rubygems.org/gems/rack-mini-profiler/versions/0.10.5
                                          # https://github.com/MiniProfiler/rack-mini-profiler/releases

  # Brakeman detects security vulnerabilities in Ruby on Rails applications via
  # static analysis.
  gem 'brakeman',               '3.7.2', require: false # https://rubygems.org/gems/brakeman/versions/3.7.2
                                          # https://github.com/presidentbeef/brakeman/tree/v3.7.2
                                          # https://github.com/presidentbeef/brakeman/blob/master/CHANGES
                                          # https://github.com/presidentbeef/brakeman/releases

  # Guard::Brakeman allows you to automatically run Brakeman tests when files
  # are modified.
  gem 'guard-brakeman',         '0.8.3'   # https://rubygems.org/gems/guard-brakeman/versions/0.8.3
                                          # https://github.com/guard/guard-brakeman
                                          # https://github.com/guard/guard-brakeman/blob/master/HISTORY.md

end

group :test do

  # Create customizable MiniTest output formats.
  gem 'minitest-reporters',     '1.1.16'  # https://rubygems.org/gems/minitest-reporters/versions/1.1.16
                                          # https://github.com/kern/minitest-reporters/blob/master/CHANGELOG.md
                                          # https://github.com/kern/minitest-reporters/releases
                                          # https://github.com/kern/minitest-reporters/compare/v1.1.8...v1.1.9
                                          # https://github.com/kern/minitest-reporters/compare/v1.1.9...v1.1.14
                                          # https://github.com/kern/minitest-reporters/compare/v1.1.14...v1.1.15
                                          # https://github.com/kern/minitest-reporters/compare/v1.1.15...v1.1.16

  # MiniBacktrace allows you to take advantage of the Rails.backtrace_cleaner
  # when using MiniTest.
  gem 'mini_backtrace',         '0.1.3'   # https://rubygems.org/gems/mini_backtrace/versions/0.1.3
                                          # https://github.com/metaskills/mini_backtrace/tree/v0.1.3
                                          # https://github.com/metaskills/mini_backtrace/releases

  # Guard::Minitest automatically run your tests with Minitest framework (much
  # like autotest).
  gem 'guard-minitest',         '2.4.6'   # https://rubygems.org/gems/guard-minitest/versions/2.4.6
                                          # https://github.com/guard/guard-minitest/tree/v2.4.6
                                          # https://github.com/guard/guard-minitest/releases

  # Suggested by https://travis-ci.org/basimilch/basimilch-app
  gem 'codeclimate-test-reporter', '1.0.8', require: nil # https://rubygems.org/gems/codeclimate-test-reporter/versions/1.0.8
                                          # https://rubygems.org/gems/codeclimate-test-reporter/versions
                                          # https://github.com/codeclimate/ruby-test-reporter/releases

  # Extracting `assigns` and `assert_template` from ActionDispatch.
  # DOC: http://guides.rubyonrails.org/v5.1.3/upgrading_ruby_on_rails.html#rails-controller-testing
  gem 'rails-controller-testing', '1.0.2' # https://rubygems.org/gems/rails-controller-testing/versions/1.0.2
                                          # https://github.com/rails/rails-controller-testing

end

group :production do

  # Run Rails the 12factor way
  gem 'rails_12factor',         '0.0.3'   # https://rubygems.org/gems/rails_12factor/versions/0.0.3
                                          # https://github.com/heroku/rails_12factor

  # Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for
  # Ruby/Rack applications. Puma is intended for use in both development and
  # production environments. In order to get the best throughput, it is highly
  # recommended that you use a Ruby implementation with real threads like
  # Rubinius or JRuby.
  gem 'puma',                   '3.10.0'  # https://rubygems.org/gems/puma/versions/3.10.0
                                          # https://github.com/puma/puma/tree/v3.10.0
                                          # https://github.com/puma/puma/blob/master/History.txt
                                          # https://github.com/puma/puma/releases

end

group :doc do

  # rdoc generator html with javascript search index.
  gem 'sdoc',                   '0.4.2'   # https://rubygems.org/gems/sdoc/versions/0.4.2
                                          # https://github.com/zzak/sdoc/tree/v0.4.2
                                          # https://github.com/zzak/sdoc/blob/master/CHANGELOG.md
                                          # https://github.com/zzak/sdoc/releases

end
