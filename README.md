# basimilch-app

[![Build Status](https://travis-ci.org/basimilch/basimilch-app.svg)](https://travis-ci.org/basimilch/basimilch-app)
[![Code Climate](https://codeclimate.com/github/basimilch/basimilch-app/badges/gpa.svg)](https://codeclimate.com/github/basimilch/basimilch-app)
[![Test Coverage](https://codeclimate.com/github/basimilch/basimilch-app/badges/coverage.svg)](https://codeclimate.com/github/basimilch/basimilch-app/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/basimilch/basimilch-app.svg)](https://gemnasium.com/github.com/basimilch/basimilch-app)
[![Inline docs](http://inch-ci.org/github/basimilch/basimilch-app.svg?branch=master)](http://inch-ci.org/github/basimilch/basimilch-app)

Web app of the [basimilch] cooperative.

[basimilch]: http://basimil.ch

Done with [Ruby] on [Rails].

[Ruby]: https://www.ruby-lang.org/en/
[Rails]: http://rubyonrails.org

## First steps in Rails

If you are new to Rails, you might want to take the time to read at
least the official [Getting Started with Rails] guide. If you are
interested in a more in-depth introduction to Ruby on Rails
development you might want to look at the _excellent_ [Rails Tutorial]
by [Michael Hartl] including more than 15 hours of screencast lessons.
The corresponding [Rails Tutorial Book] can be read online for free.

[Getting Started with Rails]: http://guides.rubyonrails.org/v5.1.4/getting_started.html
[Rails Tutorial]: https://www.railstutorial.org/
[Michael Hartl]: http://www.michaelhartl.com
[Rails Tutorial Book]: https://www.railstutorial.org/book/_single-page

## Dev documentation

### Ruby

- [Ruby Code (v2.4.3)] _([`ruby` releases])_
- [Ruby 2.4.3 Core Documentation]
- [Ruby 2.4.3 Standard Library Documentation]
- [Ruby Style Guide]
- [`rvm`] as the Ruby Version Manager _([`rvm` releases])_

[Ruby Code (v2.4.3)]: https://github.com/ruby/ruby/tree/v2_4_3
[`ruby` releases]: https://github.com/ruby/ruby/releases
[Ruby 2.4.3 Core Documentation]: http://ruby-doc.org/core-2.4.3/
[Ruby 2.4.3 Standard Library Documentation]: http://ruby-doc.org/stdlib-2.4.3/
[Ruby Style Guide]: https://github.com/bbatsov/ruby-style-guide
[`rvm`]: https://rvm.io
[`rvm` releases]: https://github.com/rvm/rvm/releases

### Rails

- [Rails Code (v5.1.4)] _([`rails` releases])_
- [The API Documentation (v5.1.4)]
- [Ruby on Rails Guides (v5.1.4)]

Beyond these official guides, it can be useful to read [The Beginner's
Guide to Rails Helpers].

[Rails Code (v5.1.4)]: https://github.com/rails/rails/tree/v5.1.4
[`rails` releases]: https://github.com/rails/rails/releases
[The API Documentation (v5.1.4)]: http://api.rubyonrails.org/v5.1.4/
[Ruby on Rails Guides (v5.1.4)]: http://guides.rubyonrails.org/v5.1.4/
[The Beginner's Guide to Rails Helpers]: http://mixandgo.com/blog/the-beginner-s-guide-to-rails-helpers

## Setup `dev` environment

- [Install `rvm`]

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

> **NOTE:** If you already have installed it you can [upgrade `rvm`]
> with `rvm get stable`.

- [Install `ruby` version 2.4.3]

```bash
rvm install 2.4.3
```

- [Install `bundle`]

```bash
gem install bundler
```

- Go to the app directory and install the `gem`s defined in the
[`Gemfile.lock`] with `bundle`:

```bash
bundle install
```

- `rails` version 5.1.4 gets installed by the previous action. If
you want to start a new project at this point you should manually
install `rails` instead: `gem install rails -v 5.1.4`)

- [heroku] is used for the production server. To deploy, install the
[heroku toolbelt].

[Install `rvm`]: https://rvm.io/rvm/install
[upgrade `rvm`]: https://rvm.io/rvm/upgrading
[Install `ruby` version 2.4.3]: https://rvm.io/rubies/installing
[Install `bundle`]: https://rvm.io/integration/bundler
[`Gemfile.lock`]: Gemfile.lock

## Setup dev environment on [`Cloud9`]

You can easily setup a development environment online at [`Cloud9`]
(aka [`c9.io`]).

- Create a new machine at [`c9.io`]

- Bootstrap the environment:

```bash
./config_c9io_machine.sh
```

If everything when well the DB should have been seeded with dummy data
and the tests should have seen executed.

To [run the `rails server` on `Cloud9`] you have to provide the proper
IP and port running following command:

```bash
rails server -b $IP -p $PORT
```

[`Cloud9`]: https://c9.io/
[`c9.io`]: https://c9.io/
[run the `rails server` on `Cloud9`]: https://community.c9.io/t/running-a-rails-app/1615

## Rails console

As mentioned in the [section 4.2 of the Rails Tutorial Book]:

> Our principal tool for learning Ruby will be the Rails console, a
> command-line program for interacting with Rails applications (...)

The Rails console can be started with `rails console` (or `rails c`
for short).

As suggested in the aforementioned section, adding following
configuration in the `~/.irbrc` file will simplify the display of the
console:

```bash
cat << EOF >> ~/.irbrc
# SOURCE: https://www.railstutorial.org/book/rails_flavored_ruby#code-irbrc
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT_MODE] = false
EOF
```

[section 4.2 of the Rails Tutorial Book]: https://www.railstutorial.org/book/rails_flavored_ruby#sec-strings_and_methods

## Local server

The local Rails server can be started with:

``` bash
$ rails server
```

### Environment variables

The application expects a number of environment variables to configure
parameters like e.g. email addresses. You don't need to setup any
required environment variables by hand on your local dev machine.
Those values are automatically handled from the file [`.env`] file by
the [dotenv] gem.

[dotenv]: https://github.com/bkeepers/dotenv
[`.env`]: .env

#### Setting up environment variables in Heroku

You can set up environment variables in Heroku on the web interface
(i.e. <https://dashboard.heroku.com/apps/basimilch-dev/settings>) or
with the [heroku toolbelt]:

``` bash
$ heroku config:set RAILS_ENV=staging RACK_ENV=staging
Setting config vars and restarting example... done
RAILS_ENV: staging
RACK_ENV:  staging
```

#### Optional ENV keys

Further environment variables that are not required but you might want to set up, specially on heroku, include:

- `EMAIL_SMTP_USERNAME`
- `EMAIL_SMTP_PASSWORD`
- `EMAIL_SMTP_DOMAIN`
- `EMAIL_SMTP_ADDRESS`
- `EMAIL_SMTP_PORT`

- `EMAIL_RECIPIENTS_WHITELIST`: If this ENV variable has a non-blank
value, only addresses matching the comma-separated list of emails will
be send emails to. See the file [`config/initializers/mailer.rb`].

[`config/initializers/mailer.rb`]: config/initializers/mailer.rb

Note that those environment variables might have different values for
staging and production servers.

### Debugging

In the [`Gemfile`] here are two 'gem's that are very useful for
debugging the local application during development: [`byebug`] and
[`web-console`].

[`Gemfile`]: Gemfile

#### [`byebug`]

Dropping a `byebug` call anywhere in your code, will stop the program
and show a debug prompt in the process or terminal where the `rails
server` command is running. And in case you wonder why `debugger`
seems to do the same thing, it is indeed because [`debugger` is an
alias for `byebug`].

In order to prevent forgetting the breakpoint in production we have
modified the helper `byebug` (see `Kernel` module in
[`rails_extensions.rb`]) so that it will raise an error in the tests
to help finding the call before pushing to production.

[`byebug`]: https://github.com/deivid-rodriguez/byebug
[`debugger` is an alias for `byebug`]: https://github.com/deivid-rodriguez/byebug/blob/bb98cd60cfeceee8ce626a222346ef432e7d2a0e/lib/byebug/attacher.rb#L33
[`rails_extensions.rb`]: lib/rails_extensions.rb


#### [`web-console`]

Dropping a `console` call in a controller or view, you get a ruby
console in the browser, as explained in the [Usage Section of the
`web-console`] documentation:

> The web console allows you to create an interactive Ruby session in
> your browser. Those sessions are launched automatically in case on
> an error, but they can also be launched manually in any page.  For
> example, calling `console` in a view will display a console in the
> current page in the context of the view binding.
>
> ```html
> <% console %>
> ```
>
> Calling `console` in a controller will result in a console in the
> context of the controller action:
>
> ```ruby
> class PostsController < ApplicationController
>   def new
>     console
>     @post = Post.new
>   end
> end
> ```

In order to prevent forgetting the console in production (and to type
less) ;) we have provided the helper `ApplicationHelper#c`, i.e. you
simply need to drop a `c` in your code (e.g. in a controller) to see
a `ruby` console in the corresponding view. Using
`ApplicationHelper#c` will raise an error in the tests to help finding
the call before pushing to production.

For a good introduction about how to use the `web-console`, you might
want to have a look at the ~5min video about [how to use Web Console
in Rails 4.2].

[`web-console`]: https://github.com/rails/web-console
[Usage Section of the `web-console`]: https://github.com/rails/web-console#usage
[How to use Web Console in Rails 4.2]: https://www.youtube.com/watch?v=qK4-sQ9ssSo


## Testing

We use the testing setup suggested in the [Advanced testing setup]
section of the [Rails Tutorial Book] mentioned above. This setup
includes color enhanced representation of test results (with
[`minitest`] reporters), a `backtrace silencer` configuration and the
usage of [`Guard`] with [`guard-minitest`] for automatic test
execution of file changes.

Once everything is set up as described in the mentioned section of the
[Rails Tutorial Book], you can run [`Guard`] at the command line as
follows:

``` bash
$ bundle exec guard
```

The rules in the corresponding [`Guardfile`] are seeded with the
content of [Listing 3.42] of the [Rails Tutorial Book]. For example,
the integration tests automatically run when a controller is changed.
To run all the tests, hit `return` at the `guard>` prompt. As
mentioned in the [Rails Tutorial Book], this may sometimes give an
error indicating a failure to connect to the Spring server. To fix the
problem, just hit return again. To exit [`Guard`], press `Ctrl-D`.

The [Rails Tutorial Book] mentions also following hint:

> The Spring server is still a little quirky as of this writing, and
> sometimes Spring processes will accumulate and slow performance of
> your tests. If your tests seem to be getting unusually sluggish,
> it’s thus a good idea to inspect the system processes and kill them
> if necessary.

This can be done with, e.g.:

``` bash
$ ps aux | grep spring
$ pkill -9 -f spring
```

### Security: `brakeman` tests

We use the [`brakeman` (v3.3.2)] gem to detect security
vulnerabilities in the Ruby on Rails application via static analysis.
Used in conjunction to the [`guard-brakeman`] gem, `brakeman` is
automatically executed on files changes when running [`Guard`]. This
means that when you execute the command `bundle exec guard` suggested
above you will see both security vulnerability warnings and test
results after each file change.

> **NOTE:** In some cases warnings might be false positives, but they
> should all be seriously taken into consideration.

[heroku]: http://heroku.com
[heroku toolbelt]: https://toolbelt.heroku.com
[Advanced testing setup]: https://www.railstutorial.org/book/static_pages#sec-advanced_testing_setup
[Listing 3.42]: https://www.railstutorial.org/book/static_pages#code-guardfile
[`Guard`]: https://github.com/guard/guard
[`Guardfile`]: Guardfile
[`minitest`]: https://github.com/seattlerb/minitest
[`guard-minitest`]: https://github.com/guard/guard-minitest
[`brakeman` (v3.3.2)]: https://github.com/presidentbeef/brakeman/tree/v3.3.2
[`guard-brakeman`]: https://github.com/guard/guard-brakeman


### Use label references for associations in fixtures

At some point tests started to fails only on Travis-CI, but not
locally. It turned out that the problem occurred only on a clean test
DB (therefore on Travis-CI, because the environment is always re-
created from scratch). When executing `rake test` the test DB is not
completely cleaned up before running the tests. Executing `rake
test:db` instead does clean up the DB before starting the tests, which
allowed the same error to be reproduced locally.

It turned out that the issue was related to how the fixtures where
loaded to the test DB. Some items where not able to be created because
the required associated models did not exists yet in the DB. And
therefore, running a second time `rake test` worked without issues,
because the required associations were created in the previous run.

That pointed out to an error with the loading order of the fixtures. I
was directly using numeric ids for the fixtures, and this prevented
Rails to figure out the proper loading order. Instead of using numeric
ids, I learned how to reference them by label (see links below for
further details), which allows Rails to properly figure out the
loading order of the fixtures.

Finally I had to update the tests to take into account the new ids of
the fixtures, and the tests now consistently pass also with `rake
test:db`.

For further details:

- [ActiveRecord::FixtureSet]
- [Tricks and Tips for using Fixtures effectively in Rails]
- [unit testing - Rails fixtures -- how do you set foreign keys? - Stack Overflow]

[ActiveRecord::FixtureSet]: http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html
[Tricks and Tips for using Fixtures effectively in Rails]: http://blog.bigbinary.com/2014/09/21/tricks-and-tips-for-using-fixtures-in-rails.html
[unit testing - Rails fixtures -- how do you set foreign keys? - Stack Overflow]: http://stackoverflow.com/questions/510195/rails-fixtures-how-do-you-set-foreign-keys


## Dev DB data

Also inspired by the [Rails Tutorial Book], [section 9.3.2], we use
the _very funny_ [Faker] library :joy: to generate fake random data to
pre-populate the DB for dev purposes. This population is defined in
the file [`db/seeds.rb`]. As recommended in this article about [Rails
Migration Etiquette], to create a local DB usable for dev execute:

``` bash
$ bundle exec rake db:setup
```

This command creates a clean database directly from the file
[`db/schema.rb`], which is maintained by Rails itself, (i.e. `rake
db:schema:load`), and then seeds it with the demo data in the file
[`db/seeds.rb`] mentioned above (i.e. `rake db:seed`). Doing so you
prevent running all migrations from scratch (done with `rake
db:migrate:reset`)

To start over with a new local dev DB execute:

``` bash
$ bundle exec rake db:reset
```

This will automatically delete the previous local DB and proceed with
a `db:setup`.

To start over with a clean local dev DB without seeding it execute
following command, as inspired from [this SO answer]:

``` bash
$ bundle exec rake db:drop db:create db:schema:load
```

If the [`db/schema.rb`] is not in sync anymore with your migrations,
perform a migration after dropping and creating the database, instead
of directly loading the schema, which recreates the [`db/schema.rb`]
file:

``` bash
$ bundle exec rake db:drop db:create db:migrate
```

To learn how to perform DB operations on heroku see [Heroku > DB]
below.

[Rails Migration Etiquette]: http://jordanhollinger.com/2014/07/30/rails-migration-etiquette/
[section 9.3.2]: https://www.railstutorial.org/book/_single-page#sec-sample_users
[Faker]: https://github.com/stympy/faker
[`db/seeds.rb`]: db/seeds.rb
[`db/schema.rb`]: db/schema.rb
[this SO answer]: http://stackoverflow.com/a/4116124
[Heroku > DB]: #db

### Squashing migrations

The datamodel has evolved quite a lot during development. To simplify
things, we are merging all migrations into one initial [null
migration] before the first _production_ launch. To prevent manual
errors, we are using a gem called [`squasher`].

However, merging migrations is not a good idea after the first
production usage, or when several people are working on the same
project.

[null migration]: http://homeonrails.com/2012/11/null-migration-or-what-to-do-when-there-are-too-many-migrations/
[`squasher`]: https://github.com/jalkoby/squasher

### PostgreSql

By default Rails applications use an [SQLite] database, which has the
advantage of being self-contained in a single file and thus being
extremely easy to use and install (basically you don't have to do
anything to have it working). However Heroku runs Rails apps with a
[PostgreSql] database.

Although you can use [SQLite] in your local environment while letting
Heroku runs your app with [PostgreSql], it's generally highly
recommended to use the same database (even the same version) in
development as in production. This is also a good practice for
[twelve-factor apps].

As of this writing, Heroku uses version 9.4.x of PostgreSql. You can
check which version is currently used for you app with `heroku
pg:info`:

```
$ heroku pg:info
=== DATABASE_URL
Plan:        Hobby-dev
Status:      Available
Connections: 0/20
PG Version:  9.4.3
Created:     2015-08-04 15:30 UTC
Data Size:   8.0 MB
Tables:      6
Rows:        1663/10000 (In compliance)
```

Heroku provides [documentation to upgrade] you PostgreSql version.

To use locally PostgreSql you might follow [Heroku's own documentation
for the local setup of PostgreSQL] or watch [episode #342] of
Railcasts.com. In the case of MacOS X, the easiest way is to install
it using [`homebrew`]. The main commands are:

``` bash
brew search postgresql # To look for the version you need to install
brew install homebrew/versions/postgresql94 # Since we need version 9.4.x in out case
psql --version # Validate the installation and version
initdb /usr/local/var/postgres -E utf8    # create a database
```

As suggested by [this Belyamani's article], to start the PostgreSql
database you can install the [`lunchy gem`] as a helper:

``` bash
gem install lunchy
cp /usr/local/Cellar/postgresql94/9.4.5/homebrew.mxcl.postgresql94.plist ~/Library/LaunchAgents/
lunchy start postgres
```

As mentioned in this [SO answer], please note that `lunchy` it will
not work inside of a [`tmux`] session.

As a final step, [create a new PostgreSql user] `basimilchdbuser`,
setup the database and run the tests:

``` bash
createuser --superuser basimilchdbuser
bundle exec rake db:setup
bundle exec rake test
```

[SQLite]: https://www.sqlite.org
[PostgreSql]: http://www.postgresql.org
[12factor apps]: http://12factor.net/dev-prod-parity
[As of this writing]: https://devcenter.heroku.com/articles/heroku-postgresql#version-support-and-legacy-infrastructure
[documentation to upgrade]: https://devcenter.heroku.com/articles/upgrading-heroku-postgres-databases
[Heroku's own documentation for the local setup of PostgreSQL]: https://devcenter.heroku.com/articles/heroku-postgresql#local-setup
[episode #342]: http://railscasts.com/episodes/342-migrating-to-postgresql?autoplay=true
[`homebrew`]: https://github.com/Homebrew/homebrew
[this Belyamani's article]: https://www.moncefbelyamani.com/how-to-install-postgresql-on-a-mac-with-homebrew-and-lunchy/
[`lunchy gem`]: https://github.com/eddiezane/lunchy
[So answer]: http://superuser.com/a/898585
[`tmux`]: https://tmux.github.io
[create a new PostgreSql user]: http://www.postgresql.org/docs/9.4/static/app-createuser.html

The [`.travis.yml`] file should also [be updated] in order to let
Travis-CI properly perform the tests as explained in the [Travis
documentation].

[`.travis.yml`]: .travis.yml
[be updated]: https://github.com/basimilch/basimilch-app/compare/f7312c45ae9e3bdec66cd8f22a449e078d6817a7...8019bb1fcb8dce7b1f10023f8140cb06cac808be
[Travis documentation]: https://docs.travis-ci.com/user/database-setup/#PostgreSQL

### Error with DB

I recently had a problem with the PostgresSql DB on my computer (Mac
OS X 10.10.5), which suddenly stopped working without supposedly
having changed anything in the system. After a computer restart, the
tests refused to start with following error:

```
$ bundle exec rake test
rake aborted!
PG::ConnectionBad: could not connect to server: No such file or directory
        Is the server running locally and accepting
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?
.../.rvm/gems/ruby-2.3.1/gems/activerecord-4.2.6/lib/active_record/connection_adapters/postgresql_adapter.rb:651:in `initialize'
```

I was not able to restart the DB and ended up creating a new one (not
an issue since I had only test data that can be quickly re-seeded)
following the steps from above, in summary:

```
mv /usr/local/var/postgres{,_bak}       # to be able to start a new DB
sudo chown -R $(whoami) /usr/local      # ensure you own /usr/local
initdb /usr/local/var/postgres -E utf8  # create a database
sleep 5                                 # wait a bit until DB is up
createuser --superuser basimilchdbuser  # create a db user
bundle exec rake db:setup               # bootstrap DB
bundle exec rake test                   # test everything
```

Note: I got the DB screwed up a couple of times after updating the
ownership of `/usr/local` to fix a multi-user `brew` setting.

## Release

The CI workflow is managed by [`travis-ci.org`]. The file
[`.travis.yml`] configures and orchestrates the behavior explained
below.

### Development - `dev` branch

Each push to the `dev` branch triggers a build on [`travis-ci.org`]
which will execute the tests. If the test suite passes, Travis-CI will
deploy the new code to the test app on Heroku, automatically applying
any DB migrations if necessary (with `rake db:migrate`).

> **Note:** To prevent a commit to trigger a build, add `[ci skip]`
to the commit message as mentioned in the [Travis-CI documentation].

### Production - `master` branch

A similar thing occurs when pushing to the `master` branch: if all
tests pass, the new code will be deployed to production. As an
additional step **before deploying** in this case, the production app
**will be automatically set to maintenance mode** and **a backup of
the DB will be captured**. After the deployment and eventual DB
migrations are successful, the app is automatically set back out of
maintenance mode.

> **Note:** The setup for this automation is (as of March 2016) not
straightforward to setup for Travis-CI. For future reference, I've
created a [_gist_](https://gist.github.com/rbf/370c5fd3bf1a78d7db2f)
with the steps I ended up doing to automatically set the Heroku app in
maintenance mode and capturing a DB backup.

[`travis-ci.org`]: https://travis-ci.org/basimilch/basimilch-app
[Travis-CI documentation]: https://docs.travis-ci.com/user/customizing-the-build/#Skipping-a-build



## Localization

All displayed strings are entered in the localization file
[`de-CH.yml`]. Although currently there is only one localization (i.e.
`de-CH`), this has two main advantages:

  1. All displayed strings are gathered in one file which makes
     corrections and changes easy to manage.
  1. The work to add potential languages in the future (like e.g.
     `fr-CH` or `it-CH`) is already prepared.

For localization we use the [`rails-i18n` gem], which provides many
common locale data.

### Translate methods

The usual way to return a localized string is:

``` ruby
I18n.t 'store.title' # Lookup translation for the 'store.title' key
I18n.l Time.now      # Localize Date and Time objects to local formats
```

Those are directly available in the views, without class name, e.g.:

``` ruby
<% provide(:title, t('users.index.title')) %>
```

#### Automatic translation scoping by view

As described in the ["Lazy" Lookup] section of the mentioned guide, if
the following key hierarchy is defined in the dictionary:

``` yaml
de-CH:
  users:
    index:
      title: "Alle Benutzer"
```
The value of `users.index.title` inside the [`app/views/users/index.html.erb`] view template can be looked up like this _(note the dot)_:

``` ruby
<% provide(:title, t('.title')) %>
```

#### Interpolation

Variables can be interpolated in the localization string like so:

``` yaml
de-CH:
  message: "Hoi %{name}!"
```

``` ruby
I18n.t :thanks, name: 'Jeremy'
```


For more details about how localization work you might refer to the
[`i18n` Rails guide].

[`de-CH.yml`]: config/locales/de-CH.yml
[`rails-i18n` gem]: https://github.com/svenfuchs/rails-i18n
["Lazy" Lookup]: http://guides.rubyonrails.org/i18n.html#lazy-lookup
[`app/views/users/index.html.erb`]: app/views/users/index.html.erb
[`i18n` Rails guide]: http://guides.rubyonrails.org/i18n.html

## Passwordless authentication

There are [lots of authentication libraries] ready to use with Ruby on
Rails. However in this application we based our implementation on the
content of [Chapter 10: "Account activation and password reset"] of
the [Rails Tutorial Book] by [Michael Hartl].

Even [`Devise`], one on the most popular authentication libraries in
this context, recommends to follow the indications of the mentioned
chapter instead of using the library itself when beginning with Rails
in order to get used to it.

Our first implementation followed the traditional
`username`/`password` model described in the documentation mentioned
above. Very soon, though, we switched to a passwordless login workflow
which offers [plenty of advantages] for our use case. When a user
wants to log in the application, she requests a `login code` to her
email address, which is immediately delivered. She can then log in by
either manually entering the code into the corresponding field in the
browser or by clicking on the code in the email itself. The `login
code` is only valid 5 minutes and has to be used in the **same
computer and browser** where it has been requested.

[lots of authentication libraries]: https://www.ruby-toolbox.com/categories/rails_authentication
[Chapter 10: "Account activation and password reset"]: https://www.railstutorial.org/book/account_activation_password_reset
[`Devise`]: https://github.com/plataformatec/devise#starting-with-rails
[plenty of advantages]: https://medium.com/search?q=passwordless

## Geolocalization

To validate the user postal addresses and IP addresses on singup we
use the geolocalization library [Geocoder `v1.3.7`]. This library will
allow us also operations related to geographical relations between
users, depots and other entities.

[Geocoder `v1.3.7`]: https://github.com/alexreisner/geocoder/tree/v1.3.7

### Google Geocode API and Usage Limits

We have configured the Geocoder `gem` to use the [Google Geocode API]
with the [`:google`] symbol. The official [Usage Limits] of the
[Google Geocode API] allow up to 2,500 free requests per day (and 10
requests per second). However, after releasing the app to Heroku, we
realized that the geolocation API was returning a `quota exceeded`
error even if we were far below the theoretical limits. As mentioned
in [several](http://stackoverflow.com/a/6782602)
[places](http://blog.pardner.com/2013/12/avoid-rate-limit-errors-when-geocoding-in-a-heroku-app/), this seems related to the fact that
Google counts the usage against the requesting IP address. Thus in
PaaS environments like Heroku, public IPs used to perform such API
requests are frequently shared, leaving individual apps out of quota
quickly. One way to workaround this limitation is to use a service
like [QuotaGuard]. However, this service is too expensive for our
needs. Luckily, the [Google Geocode API] allows you to [get an API
key] for it (credit card needed), which allows to count the quota
against the key instead of the IP address.

[Google Geocode API]: https://developers.google.com/maps/documentation/geocoding/intro
[`:google`]: https://github.com/alexreisner/geocoder/tree/v1.3.0#google-google
[Usage Limits]: https://developers.google.com/maps/documentation/geocoding/usage-limits
[QuotaGuard]: https://elements.heroku.com/addons/quotaguard
[get an API key]: https://developers.google.com/maps/documentation/geocoding/get-api-key

## Model auditing and versioning

### `paper_trail`

We use the gem [`paper_trail` (v5.1.1)] to audit changes on models.
This gem creates versions each time a model item changes by simply
adding `has_paper_trail` to the model. It allows to inspect, compare
or revert to how things looked at a given point in time.

While following the [installation] documentation, we added the option
`--with-changes` as mentioned in the [diffing versions] section. The
final installation commands were the following:

``` bash
$ bundle exec rails generate paper_trail:install --with-changes
   create  db/migrate/20160111140705_create_versions.rb
   create  db/migrate/20160111140706_add_object_changes_to_versions.rb
$ bundle exec rake db:migrate
   ...
```

The option `--with-changes` adds an additional column to the
`Versions` table that allows to directly query the changes between
directly adjacent versions with the method `.changeset`. E.g. to learn
what last changed in a user do:

``` ruby
User.find(42).update(first_name: "Bar")
# => true
User.find(42).update(first_name: "Foo")
# => true
User.find(42).versions.last.changeset
# => {"first_name"=>["Foo", "Bar"],
#     "updated_at"=>[2016-01-11 14:13:30 UTC, 2016-01-11 14:13:44 UTC]}
```

Finally we also added two further columns `request_remote_ip` and
`request_user_agent` to the `Versions` table to store [metadata from
controllers] in order to track from where the change was originated.
The population of this metadata is implemented in the file
[`/app/controllers/application_controller.rb`].

[`paper_trail` (v5.1.1)]: https://github.com/airblade/paper_trail/tree/v5.1.1
[installation]: https://github.com/airblade/paper_trail/tree/v5.1.1#1b-installation
[diffing versions]: https://github.com/airblade/paper_trail/tree/v5.1.1#3c-diffing-versions
[metadata from controllers]: https://github.com/airblade/paper_trail/tree/v5.1.1#metadata-from-controllers
[`/app/controllers/application_controller.rb`]: /app/controllers/application_controller.rb

### `public_activity`

We use the gem [`public_activity`] [(v1.4.3)]<span>[*](#public_activity_gem_version)</span> to record activities in
the application.

[`public_activity`]: https://github.com/chaps-io/public_activity/tree/v1.4.1
[(v1.4.3)]: https://rubygems.org/gems/public_activity/versions/1.4.3

<i><a name="public_activity_gem_version">*</a> Note that the `gem`
version in Rubygems.org is `v1.4.3` but the tag in GitHub.com is
`v1.4.1`.</i>

## Notes on Rails

### Implicit routing

Adding  `resources :users` to the `config/routes.rb` file generates
all the actions needed for a RESTful Users resource, along with a
large number of _named routes_ to generate user URLs. The resulting
correspondence of URLs, actions, and named routes is shown in following table:

HTTP request | URL     | Action   | Named route      | Purpose
-------------|---------|----------|------------------|--------
`GET`    | `/users`    | `index`  |`users_path`      | page to list all users
`GET`    | `/users/1`  | `show`   |`user_path(user)` | page to show user
`GET`    | `/users/new`|  `new`   |`new_user_path`   | page to make a new user (signup)
`POST`   | `/users`    | `create` |`users_path`      | create a new user
`GET`    | `/users/1/edit`| `edit`|`edit_user_path(user)` | page to edit user with id 1
`PATCH`  | `/users/1`  | `update` |`user_path(user)` | update user
`DELETE` | `/users/1`  | `destroy`|`user_path(user)` | delete user

_Source: [Table 7.1.] in [Rails Tutorial Book]_

[Table 7.1.]: https://www.railstutorial.org/book/_single-page#table-RESTful_users

### Session cookie data and security

In Rails 2 & 3, the value of the session is stored in a cookie as a
`base64` encoded serialized string with an added signature. Session
data is thus almost clear text (see [Decoding Rails Session Cookies]
for example about how to decode it).

However, in Rails 4 (which we are using), the value of the cookie is
an encrypted string. You have to have access to both the production
`secret_key_base` and to the source code of the application so that
you can use the built-in infrastructure to decode the session as
explained in [Session storage and security in Rails] and demoed in
[this gist].

For more info about security, read the [Ruby on Rails Security Guide].

As a general reminder, cookies can only contain [4K of data] for the
entire cookie, including name, value, expiry date, etc.

[Decoding Rails Session Cookies]: http://www.andylindeman.com/decoding-rails-session-cookies/
[Session storage and security in Rails]: http://dev.housetrip.com/2014/01/14/session-store-and-security/
[this gist]: https://gist.github.com/profh/e36e5dd0bec124fef04c
[Ruby on Rails Security Guide]: http://guides.rubyonrails.org/v5.1.4/security.html
[4K of data]: http://stackoverflow.com/questions/640938/what-is-the-maximum-size-of-a-web-browsers-cookies-key

### Reminder about migrations

Active Record provides a generator to handle the generation of
migration files:

```
rails generate migration name_of_the_migration
```

Additionally, as stated in the [RailsGuide about migrations]:

> If the migration name is of the form "AddXXXToYYY" or
> "RemoveXXXFromYYY" and is followed by a list of column names and
> types then a migration containing the appropriate add_column and
> remove_column statements will be created.

Note that this also works for _`snake_case`_ migration names as we use
it here: `add_xxx_to_yyy` or `remove_xxx_from_yyy`. The _list of
column names and types_ mentioned in the quoted documentation text has
to be given in the following form: `column_name:data_type`.

As an example, to remove columns there is a `rails generate` operation
that will generate the expected migration:

```
$ rails generate migration remove_password_related_columns_from_users password_digest:string password_reset_digest:string password_reset_at:datetime password_reset_sent_at:datetime
      invoke  active_record
      create    db/migrate/20160103160340_remove_password_related_columns_from_users.rb

$ bundle exec rake db:migrate
== 20160103160340 RemovePasswordRelatedColumnsFromUsers: migrating ============
-- remove_column(:users, :password_digest, :string)
   -> 0.0751s
-- remove_column(:users, :password_reset_digest, :string)
   -> 0.0728s
-- remove_column(:users, :password_reset_at, :datetime)
   -> 0.0680s
-- remove_column(:users, :password_reset_sent_at, :datetime)
   -> 0.0746s
== 20160103160340 RemovePasswordRelatedColumnsFromUsers: migrated (0.2908s) ===
```

It might be also interesting to read [this SO answer about creating
simple vs compound indexed], as well as Heroku's own documentation
about [Efficient Use of PostgreSQL Indexes].

[RailsGuide about migrations]: http://guides.rubyonrails.org/v5.1.4/active_record_migrations.html#creating-a-migration
[this SO answer about creating simple vs compound indexed]: http://stackoverflow.com/a/1049392
[Efficient Use of PostgreSQL Indexes]: https://devcenter.heroku.com/articles/postgresql-indexes

#### Test DB out of sync

If the tests seems to fail for a weird reason, please make sure that
the test DB is in sync with the [`db/schema.rb`]. As suggested in
["Maintaining The Test Database Schema"], you have to execute
[`db:test:prepare`]:

``` bash
bundle exec db:test:prepare
```

In [some places](http://stackoverflow.com/a/28324956), this command
is supposed deprecated (but worked for me :confused:). They recommend
to execute instead:

``` bash
bundle exec rake db:migrate RAILS_ENV=test
```

Alternatively, if the [`db/schema.rb`] is correct you can reload it to
the `test` environment with:

``` bash
bundle exec rake db:schema:load RAILS_ENV=test
```

Please make sure that neither the tests nor the `rails console` are
running when applying migrations, since this can result in such
misalignments.

Another common cause of leaving the test DB in an inconsistent state
is when rollbacking a migration (during dev) with `db:rollback`.

For a comprehensive description of all `db:` rake tasks you can check
the code at [`railties/databases.rake`].

["Maintaining The Test Database Schema"]: http://guides.rubyonrails.org/v5.1.4/testing.html#maintaining-the-test-database-schema

[`db:test:prepare`]: https://github.com/rails/rails/blob/v5.1.4/activerecord/lib/active_record/railties/databases.rake#L359-L364

[`railties/databases.rake`]: https://github.com/rails/rails/blob/v5.1.4/activerecord/lib/active_record/railties/databases.rake

### Active Record `scopes`

For a gut introduction to Active Record `scopes` you might want to
read the article [Advanced Active Record in Rails 4 | 9.1 Scopes].

[Advanced Active Record in Rails 4 | 9.1 Scopes]: http://www.informit.com/articles/article.aspx?p=2220311

## Heroku

### Add-ons

We currently use following [Heroku add-ons]:

- [New Relic], which provides deep information about the performance of
  the web application as it runs in production. It requires the [New Relic add-on]
  and the [`newrelic_rpm` gem].

- [Sentry], which enables live error tracking to monitor and fix application
  crashes in real time. It requires the [Sentry add-on] and the
  [`sentry-raven` gem].


[Heroku add-ons]: https://elements.heroku.com/addons

[New Relic]: https://newrelic.com
[New Relic add-on]: https://elements.heroku.com/addons/newrelic
[`newrelic_rpm` gem]: https://rubygems.org/gems/newrelic_rpm

[Sentry]: https://sentry.io
[Sentry add-on]: https://elements.heroku.com/addons/sentry
[`sentry-raven` gem]: https://rubygems.org/gems/sentry-raven


### Timeout awaiting process: `heroku run` error

As mentioned in the heroku documentation about the [Timeout awaiting
process]:

> The heroku run command opens a connection to Heroku on port 5000. If
> your local network or ISP is blocking port 5000, or you are
> experiencing a connectivity issue, you will see an error similar to:
>
> ```
> $ heroku run rails console
> Running rails console attached to terminal...
> Timeout awaiting process
> ```

In the logs this error appears as `Error R13 (Attach error) -> Failed
to attach to process`. If you cannot fix the problem (e.g. opening port
`5000`), some tasks can be performed in a [`detached` mode] as a
workaround:

```
$ heroku run:detached rake db:migrate
Running rake db:migrate... up, run.2
Use 'heroku logs -p run.2' to view the log output.
```

But not all command can be executed in a background way: e.g.
`heroku run rails console` makes no sense in a detached context.

[Timeout awaiting process]: https://devcenter.heroku.com/articles/one-off-dynos#timeout-awaiting-process
[`detached` mode]: https://devcenter.heroku.com/articles/one-off-dynos#running-tasks-in-background

### Heroku DB

#### Fresh **dev** DB

To start with a fresh **dev** DB on Heroku do following commands:

```
heroku pg:reset --app basimilch-dev DATABASE
heroku run rake db:migrate
heroku run rake db:seed
```

To create a user with your email address, start a rails console on heroku (`heroku run rails console`) an run following command:

```
User.new(first_name: "your_first_name", last_name: "your_last_name", email: "your_email@example.com", admin: true, activation_sent_at: Time.current).save(validate: false)
```

#### Backup

The following examples are the main `heroku` commands related to the management
of the Postgres database. Please refer to the official
[Heroku documentation about Postgres DB backups](https://devcenter.heroku.com/articles/heroku-postgres-backups)
for more details and further commands.

##### Schedule automatic backup of **prod** DB

Every night at 3:00am a backup of the production database is automatically
created. To schedule automatic backups run the following command:

```
heroku pg:backups:schedule DATABASE_URL --at '03:00 Europe/Zurich' --app basimilch
```

To verify the scheduled backups run the following command:

```
heroku pg:backups:schedules --app basimilch
```

Please note that when the database plan is changed or the database instance is
modified **the backup schedule might be lost**. Please verify the expected
backup schedule in such cases.

[_(Link to relevant Heroku documentation)_](https://devcenter.heroku.com/articles/heroku-postgres-backups#scheduling-backups)

##### Backup **dev** DB

```
heroku pg:backups capture --app basimilch-dev
```

[_(Link to relevant Heroku documentation)_](https://devcenter.heroku.com/articles/heroku-postgres-backups#creating-a-backup)

##### Restore last **dev** DB backup

```
heroku pg:backups restore --app basimilch-dev
```

[_(Link to relevant Heroku documentation)_](https://devcenter.heroku.com/articles/heroku-postgres-backups#restoring-backups)

#### Copy **prod** DB to **dev**

Having real data on the **dev** DB might be useful to check that
everything works as expected before deploying to production, specially
before big or non-trivial migrations. To copy the last backup from the
**prod** DB to the **dev** DB on heroku do following commands:

_Note that we start doing a backup of the **dev** DB, which might be
optional, depending on your needs._

```
heroku pg:backups capture --app basimilch-dev
heroku pg:backups restore $(heroku pg:backups public-url --app basimilch) DATABASE_URL --app basimilch-dev
```

To learn more about this procedure and about the
`heroku pg:backups restore` commands visit the
[Heroku documentation page](https://devcenter.heroku.com/articles/heroku-postgres-backups#restoring-backups)
and [this StackOverflow thread](https://stackoverflow.com/a/8283931).

#### Push and pull DB

Please refer to the Heroku documentation about [`pg:push` and
`pg:pull`] to learn about how to get a copy of the DB from `dev` or
`prod` to your local machine (or the other way around):

> `pg:pull` can be used to pull remote data from a Heroku Postgres
> database to a database on your local machine. The command looks
> like this:
>
> ```bash
> $ heroku pg:pull HEROKU_POSTGRESQL_MAGENTA mylocaldb --app sushi
> ```

> Like pull but in reverse, `pg:push` will push data from a local
> database into a remote Heroku Postgres database. The command looks
> like this:
>
> ```bash
> $ heroku pg:push mylocaldb HEROKU_POSTGRESQL_MAGENTA --app sushi
> ```

For reference, the first `prod` DB was imported locally from the
previously used spreadsheet and `pg:push`ed into production.

[`pg:push` and `pg:pull`]: https://devcenter.heroku.com/articles/heroku-postgresql#pg-push-and-pg-pull

## SSL Certificates

We are using an SSL certificate from [Let's encrypt] to secure
communications between the browser and the application. The exact
instructions about creating and installing the certificate were
followed from this [_Medium_ article] and [Heroku's own documentation
about SSL]. As explained in both articles, for that we had to add the
non-free [Heroku SSL addon].

[Let's encrypt]: https://letsencrypt.org
[_Medium_ article]: https://sikac.hu/use-let-s-encrypt-tls-certificate-on-heroku-65f853870d90#.toyin35g1
[Heroku's own documentation about SSL]: https://devcenter.heroku.com/articles/ssl-endpoint
[Heroku SSL addon]: https://elements.heroku.com/addons/ssl

### Certificate renewal

The free certificates from [Let's encrypt] are valid (as of now) for
**only 3 months**. The certificate for `meine.basimil.ch` can be
renewed form the `Cloud9` IDE with the following steps from the
[Let's encrypt documentation]:

``` bash
./letsencrypt-auto renew --manual-public-ip-logging-ok
```

_Note that `letsencrypt-auto` is the official "Let’s Encrypt" client,
but the other [several `lets-encrypt` clients] available._

To verify the certificate, the corresponding domain needs to serve a
challenge string on a secret URL provided in the output of the command
above, e.g.:

``` bash
-------------------------------------------------------------------------------
Processing /etc/letsencrypt/renewal/meine.basimil.ch.conf
-------------------------------------------------------------------------------
Make sure your web server displays the following content at
http://meine.basimil.ch/.well-known/acme-challenge/wheQaqVGXFyWh6c6-8PtX-pMJxyl6YE before continuing:

wheQaqVGXFyWh6c6-8PtX-pMJxyl6YE._vNsdaf0TA_jMgfijgFq3xasa9xIFyNfdijf2U

(...)
Press ENTER to continue
```

To serve that file, you have to set up the `ENV` variable
`LETSENCRYPT_CHALLENGE` with the value `filename,challenge`. For the
example output above, that would be:

``` bash
heroku config:add --app basimilch LETSENCRYPT_CHALLENGE=wheQaqVGXFyWh6c6-8PtX-pMJxyl6YE,wheQaqVGXFyWh6c6-8PtX-pMJxyl6YE._vNsdaf0TA_jMgfijgFq3xasa9xIFyNfdijf2U
```

After the app has been restarted on Heroku, verify that the expected
challenge is returned at the requested URL, e.g. in that case
`http://meine.basimil.ch/.well-known/acme-challenge/wheQaqVGXFyWh6c6
-8PtX-pMJxyl6YE`,
and proceed with the renewal command by pressing `ENTER`.

Once the certificate has successfully been renewed, the corresponding
files must be updated on Heroku:

``` bash
heroku certs:update --app basimilch /etc/letsencrypt/live/meine.basimil.ch/fullchain.pem /etc/letsencrypt/live/meine.basimil.ch/privkey.pem
```

You will be asked to confirm. To proceed, type `basimilch`.

**Note that it might take up to five minutes until you actually see
that the certificates have been updated.**

To verify that everything has gone as expected, you might list the
certificates of the app with following command:

``` bash
heroku certs:info --app basimilch
```

[several `lets-encrypt` clients]: https://www.metachris.com/2015/12/comparison-of-10-acme-lets-encrypt-clients/
[Let's encrypt documentation]: https://letsencrypt.org/getting-started/#renewing-a-certificate

