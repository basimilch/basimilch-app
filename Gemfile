# Gemfile from http://sample-app-gemfile.railstutorial.org
# Use 'bundle install' on the command line to install all this gems.
# Info about Gemfile.lock and why to commit:
# http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source 'https://rubygems.org'

# NOTE: After updating ruby, you have to install it and all the gems again:
#         $ rvm install 2.4.1 && gem install bundle && bundle install
#       The first and last commands might take long to execute (ca. 5 min).
ruby '2.4.3'
# https://github.com/ruby/ruby/tree/v2_4_1
# https://www.ruby-lang.org/en/news/2015/12/25/ruby-2-3-0-released/
# https://www.ruby-lang.org/en/news/2016/04/26/ruby-2-3-1-released/
# https://www.ruby-lang.org/en/news/2017/03/22/ruby-2-4-1-released/
# https://www.ruby-lang.org/en/news/2017/12/14/ruby-2-4-3-released/
# https://github.com/ruby/ruby/blob/v2_4_1/NEWS

# NOTE: Use use fixed gem versions instead of ruby's pessimistic version
#       constraint operator (~>) to manually control the updates (and calling
#       'bundle update' by mistake) and to maintain the proper url abouth the
#       gem. To know which gems to update we can run 'bundle outdated' and
#       update the versions in this Gemfile accordingly.
#       More info and references: https://stackoverflow.com/q/9265213

# DOC: http://guides.rubyonrails.org/v5.1.4/upgrading_ruby_on_rails.html
# https://rubygems.org/gems/rails/versions/5.1.4
# CHANGELOG: https://github.com/rails/rails/search?q=filename%3Achangelog.md
# https://github.com/rails/rails/tree/v5.1.4
# https://github.com/rails/rails/compare/v4.2.5.2...v4.2.6
# https://github.com/rails/rails/compare/v4.2.6...v4.2.9
# https://github.com/rails/rails/compare/v4.2.9...v5.0.4
# https://github.com/rails/rails/compare/v5.0.4...v5.1.3
# https://github.com/rails/rails/compare/v5.1.3...v5.1.4
# https://github.com/rails/rails/releases
# http://weblog.rubyonrails.org/releases/
gem 'rails',                        '5.1.4'

# bcrypt() is a sophisticated and secure hash algorithm designed by The OpenBSD
# project for hashing passwords. The bcrypt Ruby gem provides a simple wrapper
# for safely handling passwords.
# https://rubygems.org/gems/bcrypt/versions/3.1.11
# CHANGELOG: https://github.com/codahale/bcrypt-ruby/releases
gem 'bcrypt',                       '3.1.11'

# will_paginate provides a simple API for performing paginated queries with
# Active Record, DataMapper and Sequel, and includes helpers for rendering
# pagination links in Rails, Sinatra and Merb web apps.
# https://rubygems.org/gems/will_paginate/versions/3.1.6
# CHANGELOG: https://github.com/mislav/will_paginate/releases
gem 'will_paginate',                '3.1.6'

# Hooks into will_paginate to format the html to match Twitter Bootstrap
# styling.
# https://rubygems.org/gems/bootstrap-will_paginate/versions/1.0.0
# CHANGELOG: https://github.com/yrgoldteeth/bootstrap-will_paginate/releases
gem 'bootstrap-will_paginate',      '1.0.0'

# bootstrap-sass is a Sass-powered version of Bootstrap 3, ready to drop right
# into your Sass powered applications.
# https://rubygems.org/gems/bootstrap-sass/versions/3.3.7
# CHANGELOG: https://github.com/twbs/bootstrap-sass/blob/master/CHANGELOG.md
gem 'bootstrap-sass',               '3.3.7'

# Sass adapter for the Rails asset pipeline.
# https://rubygems.org/gems/sass-rails/versions/5.0.7
# CHANGELOG: https://github.com/rails/sass-rails/releases
gem 'sass-rails',                   '5.0.7'

# Uglifier minifies JavaScript files by wrapping UglifyJS to be accessible in
# Ruby.
# https://rubygems.org/gems/uglifier/versions/4.1.2
# CHANGELOG: https://github.com/lautis/uglifier/blob/master/CHANGELOG.md
gem 'uglifier',                     '4.1.2'

# CoffeeScript adapter for the Rails asset pipeline.
# https://rubygems.org/gems/coffee-rails/versions/4.2.2
# CHANGELOG: https://github.com/rails/coffee-rails/blob/master/CHANGELOG.md
gem 'coffee-rails',                 '4.2.2'

# Provides jQuery and the jQuery-ujs driver for the Rails 4+ application.
# https://rubygems.org/gems/jquery-rails/versions/4.3.1
# CHANGELOG: https://github.com/rails/jquery-rails/blob/master/CHANGELOG.md
gem 'jquery-rails',                 '4.3.1'

# Rails engine for Turbolinks 5 support.
# https://rubygems.org/gems/turbolinks/versions/5.0.1
# CHANGELOG: https://github.com/turbolinks/turbolinks/releases
gem 'turbolinks',                   '5.0.1'

# Create JSON structures via a Builder-style DSL
# https://rubygems.org/gems/jbuilder/versions/2.7.0
# CHANGELOG: https://github.com/rails/jbuilder/blob/master/CHANGELOG.md
gem 'jbuilder',                     '2.7.0'

# Ruby HTTP client for the Heroku API.
# https://rubygems.org/gems/platform-api/versions/2.1.0
# CHANGELOG: https://github.com/heroku/platform-api/releases
gem 'platform-api',                 '2.1.0'

# A set of common locale data and translations to internationalize and/or
# localize your Rails applications.
# https://rubygems.org/gems/rails-i18n/versions/5.0.4
# CHANGELOG: https://github.com/svenfuchs/rails-i18n/blob/master/CHANGELOG.md
gem 'rails-i18n',                   '5.0.4'

# Adds useful methods to validate, display and save phone numbers.
# https://rubygems.org/gems/phony_rails/versions/0.14.6
# CHANGELOG: https://github.com/joost/phony_rails/blob/master/CHANGELOG.md
gem 'phony_rails',                  '0.14.6'

# Provides object geocoding (by street or IP address), reverse geocoding
# (coordinates to street address), distance queries for ActiveRecord and
# Mongoid, result caching, and more.
# https://rubygems.org/gems/geocoder/versions/1.4.5
# CHANGELOG: https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md
gem 'geocoder',                     '1.4.5'

# Track changes to your models' data. Good for auditing or versioning. (i.e.
# allows undo)
# https://rubygems.org/gems/paper_trail/versions/8.1.2
# CHANGELOG: https://github.com/airblade/paper_trail/blob/master/CHANGELOG.md
gem 'paper_trail',                  '8.1.2'

# Easy activity tracking for models - similar to Github's Public Activity. (i.e.
# allows timeline).
# https://rubygems.org/gems/public_activity/versions/1.5.0
# CHANGELOG: https://github.com/chaps-io/public_activity/blob/v1.5.0/CHANGELOG.md
gem 'public_activity',              '1.5.0'

# Gem which calculates the difference between two times and returns a hash with
# the difference in terms of year, month, week, day, hour, minute and second.
# https://rubygems.org/gems/time_diff/versions/0.3.0
# CHANGELOG: https://github.com/abhidsm/time_diff/releases
gem 'time_diff',                    '0.3.0'

# pg is the Ruby interface to the PostgreSQL RDBMS.
# https://rubygems.org/gems/pg/versions/0.21.0
# CHANGELOG: https://bitbucket.org/ged/ruby-pg/src/default/History.rdoc
gem 'pg',                           '0.21.0'

# New Relic provides you with deep information about the performance of your web
# application as it runs in production.
# https://rubygems.org/gems/newrelic_rpm/versions/4.7.1.340
# CHANGELOG: https://github.com/newrelic/rpm/blob/master/CHANGELOG.md
gem 'newrelic_rpm',                 '4.7.1.340'

# A gem that provides a client interface for the Sentry error logger.
# https://rubygems.org/gems/sentry-raven/versions/2.7.1
# CHANGELOG: https://github.com/getsentry/raven-ruby/blob/master/changelog.md
gem 'sentry-raven',                 '2.7.1'

group :development, :test do

  # Used to easily generate fake data: names, addresses, phone numbers, etc. (used
  # for DB seeding)
  # https://rubygems.org/gems/faker/versions/1.8.7
  # CHANGELOG: https://github.com/stympy/faker/blob/master/CHANGELOG.md
  gem 'faker',                      '1.8.7'

  # Dropping a `byebug` (or `debugger`) call anywhere in your code, you get a
  # debug prompt.
  # https://rubygems.org/gems/byebug/versions/9.1.0
  # CHANGELOG: https://github.com/deivid-rodriguez/byebug/blob/master/CHANGELOG.md
  gem 'byebug',                     '9.1.0'

  # Preloads the application so things like console, rake and tests run faster.
  # https://rubygems.org/gems/spring/versions/2.0.2
  # CHANGELOG: https://github.com/rails/spring/blob/master/CHANGELOG.md
  gem 'spring',                     '2.0.2'

  # Autoload `dotenv` in Rails, which in its turn loads environment variables
  # from `.env` files.
  # Alternative: https://github.com/laserlemon/figaro#is-figaro-like-dotenv
  # https://rubygems.org/gems/dotenv-rails/versions/2.2.1
  # CHANGELOG: https://github.com/bkeepers/dotenv/blob/master/Changelog.md
  gem 'dotenv-rails',               '2.2.1'

  # Guard is a command line tool to easily handle events on file system
  # modifications.
  # https://rubygems.org/gems/guard/versions/2.14.1
  # CHANGELOG: https://github.com/guard/guard/releases
  gem 'guard',                      '2.14.1'

end

group :development do

  # A debugging tool for your Ruby on Rails applications. Dropping a `console`
  # call in a controller or view, you get a ruby console in the browser.
  # https://rubygems.org/gems/web-console/versions/3.5.1
  # CHANGELOG: https://github.com/rails/web-console/blob/master/CHANGELOG.markdown
  gem 'web-console',                '3.5.1'

  # FIXME: Does not work from within tmux.
  # DOC: https://github.com/Codaisseur/terminal-notifier-guard#caveats
  # gem 'terminal-notifier-guard','1.7.0' # https://github.com/Codaisseur/terminal-notifier-guard/releases

  # Profiling toolkit for Rack applications with Rails integration. Client Side
  # profiling, DB profiling and Server profiling.
  # https://rubygems.org/gems/rack-mini-profiler/versions/0.10.7
  # CHANGELOG: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/CHANGELOG.md
  gem 'rack-mini-profiler',         '0.10.7'

  # Brakeman detects security vulnerabilities in Ruby on Rails applications via
  # static analysis.
  # https://rubygems.org/gems/brakeman/versions/4.1.1
  # CHANGELOG: https://github.com/presidentbeef/brakeman/blob/master/CHANGES.md
  gem 'brakeman',                   '4.1.1', require: false

  # Guard::Brakeman allows you to automatically run Brakeman tests when files
  # are modified.
  # https://rubygems.org/gems/guard-brakeman/versions/0.8.3
  # CHANGELOG: https://github.com/guard/guard-brakeman/blob/master/HISTORY.md
  gem 'guard-brakeman',             '0.8.3'

end

group :test do

  # Create customizable MiniTest output formats.
  # https://rubygems.org/gems/minitest-reporters/versions/1.1.19
  # CHANGELOG: https://github.com/kern/minitest-reporters/blob/master/CHANGELOG.md
  gem 'minitest-reporters',         '1.1.19'

  # Guard::Minitest automatically run your tests with Minitest framework (much
  # like autotest).
  # https://rubygems.org/gems/guard-minitest/versions/2.4.6
  # CHANGELOG: https://github.com/guard/guard-minitest/releases
  gem 'guard-minitest',             '2.4.6'

  # Suggested by https://travis-ci.org/basimilch/basimilch-app
  # https://rubygems.org/gems/codeclimate-test-reporter/versions/1.0.8
  # CHANGELOG: https://github.com/codeclimate/ruby-test-reporter/blob/master/CHANGELOG.md
  gem 'codeclimate-test-reporter',  '1.0.8', require: nil

  # Extracting `assigns` and `assert_template` from ActionDispatch.
  # DOC: http://guides.rubyonrails.org/v5.1.4/upgrading_ruby_on_rails.html#rails-controller-testing
  # https://rubygems.org/gems/rails-controller-testing/versions/1.0.2
  # CHANGELOG: https://github.com/rails/rails-controller-testing/releases
  gem 'rails-controller-testing',   '1.0.2'

end

group :production do

  # Run Rails the 12factor way
  # https://rubygems.org/gems/rails_12factor/versions/0.0.3
  # https://github.com/heroku/rails_12factor
  gem 'rails_12factor',             '0.0.3'

  # Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for
  # Ruby/Rack applications. Puma is intended for use in both development and
  # production environments. In order to get the best throughput, it is highly
  # recommended that you use a Ruby implementation with real threads like
  # Rubinius or JRuby.
  # https://rubygems.org/gems/puma/versions/3.11.0
  # CHANGELOG: https://github.com/puma/puma/blob/master/History.md
  gem 'puma',                       '3.11.0'

end

group :doc do

  # rdoc generator html with javascript search index.
  # https://rubygems.org/gems/sdoc/versions/1.0.0.rc3
  # CHANGELOG: https://github.com/zzak/sdoc/blob/master/CHANGELOG.md
  gem 'sdoc',                       '1.0.0.rc3'

end
