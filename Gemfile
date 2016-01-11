# Gemfile from http://sample-app-gemfile.railstutorial.org
# Use 'bundle install' on the command line to install all this gems.
# Info about Gemfile.lock and why to commit:
# http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source 'https://rubygems.org'

ruby '2.2.1'

gem 'rails', '4.2.3'

gem 'bcrypt',                   '3.1.7'
gem 'faker',                    '1.4.2'
gem 'carrierwave',              '0.10.0'
gem 'mini_magick',              '3.8.0'
gem 'fog',                      '1.32.0'
gem 'will_paginate',            '3.0.7'
gem 'bootstrap-will_paginate',  '0.0.10'
gem 'bootstrap-sass',           '3.3.5.1'
gem 'sass-rails',               '5.0.2'
gem 'uglifier',                 '2.5.3'
gem 'coffee-rails',             '4.1.0'
gem 'jquery-rails',             '4.0.3'
gem 'turbolinks',               '2.3.0'
gem 'jbuilder',                 '2.2.3'
gem 'sdoc',                     '0.4.0', group: :doc
gem 'platform-api',             '0.3.0' # For Heroku API
gem 'rails-i18n',               '4.0.4'
gem 'phony_rails',              '0.12.9'
gem 'geocoder',                 '1.2.9'
gem 'paper_trail',              '4.0.1' # Track changes to models' data.

group :development, :test do
  gem 'sqlite3',                '1.3.9'
  gem 'byebug',                 '3.4.0'
  gem 'web-console',            '2.0.0.beta3'
  gem 'spring',                 '1.1.3'
  gem 'dotenv-rails',           '2.0.2'
end

group :test do
  gem 'minitest-reporters',     '1.0.5'
  gem 'mini_backtrace',         '0.1.3'
  gem 'guard-minitest',         '2.3.1'
end

group :production do
  gem 'pg',                     '0.17.1'
  gem 'rails_12factor',         '0.0.2'
  gem 'puma',                   '2.11.1'
end

# Suggested by https://travis-ci.org/basimilch/basimilch-app
gem "codeclimate-test-reporter", group: :test, require: nil
