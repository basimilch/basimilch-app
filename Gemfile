# Gemfile from http://sample-app-gemfile.railstutorial.org
# Use 'bundle install' on the command line to install all this gems.
# Info about Gemfile.lock and why to commit:
# http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/

source 'https://rubygems.org'

ruby '2.2.4'

# DOC: http://guides.rubyonrails.org/v4.2.5.2/upgrading_ruby_on_rails.html
gem 'rails', '4.2.5.2'

gem 'bcrypt',                   '3.1.11'
gem 'faker',                    '1.6.3' # https://github.com/stympy/faker/releases
gem 'carrierwave',              '0.10.0'
gem 'mini_magick',              '4.5.1' # https://github.com/minimagick/minimagick/releases
gem 'fog',                      '1.37.0' # https://github.com/fog/fog/releases
gem 'will_paginate',            '3.1.0' # https://github.com/mislav/will_paginate/releases
gem 'bootstrap-will_paginate',  '0.0.10'
gem 'bootstrap-sass',           '3.3.6' # https://github.com/twbs/bootstrap-sass/releases
gem 'sass-rails',               '5.0.4' # https://github.com/rails/sass-rails/releases
gem 'uglifier',                 '2.7.2' # https://github.com/lautis/uglifier/releases
gem 'coffee-rails',             '4.1.1' # https://github.com/rails/coffee-rails/releases
gem 'jquery-rails',             '4.1.0' # https://github.com/rails/jquery-rails/releases
gem 'turbolinks',               '2.5.3' # https://github.com/turbolinks/turbolinks-classic/releases
gem 'jbuilder',                 '2.4.1' # https://github.com/rails/jbuilder/releases
gem 'sdoc',                     '0.4.1', group: :doc # https://github.com/voloko/sdoc/releases
# For Heroku API
gem 'platform-api',             '0.5.0' # https://github.com/heroku/platform-api/releases
gem 'rails-i18n',               '4.0.8' # https://github.com/svenfuchs/rails-i18n/blob/master/CHANGELOG.md
gem 'phony_rails',              '0.12.13' # https://github.com/joost/phony_rails/releases
gem 'geocoder',                 '1.3.3' # https://github.com/alexreisner/geocoder/releases
# Track changes to models => allows undo
gem 'paper_trail',              '4.1.0' # https://github.com/airblade/paper_trail/releases
# Track activity => allows timeline
gem 'public_activity',          '1.4.3' # https://github.com/chaps-io/public_activity/releases
gem 'time_diff',                '0.3.0'
gem 'pg',                       '0.18.4'

group :development do
  # Dropping a `console` call in a controller or view, you get a ruby console in the browser.
  gem 'web-console',            '3.1.1' # https://github.com/rails/web-console/releases
end

group :development, :test do
  # Dropping a `byebug` (or `debugger`) call anywhere in your code, you get a debug prompt.
  gem 'byebug',                 '8.2.2' # https://github.com/deivid-rodriguez/byebug/releases
  gem 'spring',                 '1.6.4' # https://github.com/rails/spring/blob/master/CHANGELOG.md
  gem 'dotenv-rails',           '2.1.0' # https://github.com/bkeepers/dotenv/releases
end

group :test do
  gem 'minitest-reporters',     '1.1.8' # https://github.com/kern/minitest-reporters/releases
  gem 'mini_backtrace',         '0.1.3'
  gem 'guard',                  '2.13.0' # https://github.com/guard/guard/releases
  gem 'guard-minitest',         '2.4.3' # https://github.com/guard/guard-minitest/releases
  # Suggested by https://travis-ci.org/basimilch/basimilch-app
  gem 'codeclimate-test-reporter', '0.5.0', require: nil # https://github.com/codeclimate/ruby-test-reporter/releases
end

group :production do
  gem 'rails_12factor',         '0.0.3'
  gem 'puma',                   '2.11.1'
end
