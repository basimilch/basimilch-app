# basimilch-app

[![Build Status](https://travis-ci.org/basimilch/basimilch-app.svg)](https://travis-ci.org/basimilch/basimilch-app)
[![Code Climate](https://codeclimate.com/github/basimilch/basimilch-app/badges/gpa.svg)](https://codeclimate.com/github/basimilch/basimilch-app)
[![Test Coverage](https://codeclimate.com/github/basimilch/basimilch-app/badges/coverage.svg)](https://codeclimate.com/github/basimilch/basimilch-app/coverage)
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

[Getting Started with Rails]: http://guides.rubyonrails.org/v4.2.5.2/getting_started.html
[Rails Tutorial]: https://www.railstutorial.org/
[Michael Hartl]: http://www.michaelhartl.com
[Rails Tutorial Book]: https://www.railstutorial.org/book/_single-page

## Dev documentation

### Ruby

- [Ruby Code (v2.2.4)] _([`ruby` releases])_
- [Ruby 2.2.4 Standard Library Documentation]
- [Ruby Style Guide]
- [`rvm`] as the Ruby Version Manager _([`rvm` releases])_

[Ruby Code (v2.2.4)]: https://github.com/ruby/ruby/tree/v2_2_4
[`ruby` releases]: https://github.com/ruby/ruby/releases
[Ruby 2.2.4 Standard Library Documentation]: http://ruby-doc.org/stdlib-2.2.4/
[Ruby Style Guide]: https://github.com/bbatsov/ruby-style-guide
[`rvm`]: https://rvm.io
[`rvm` releases]: https://github.com/rvm/rvm/releases

### Rails

- [Rails Code (v4.2.5.2)] _([`rails` releases])_
- [The API Documentation (v4.2.5.2)]
- [Ruby on Rails Guides (v4.2.5.2)]

Beyond these official guides, it can be useful to read [The Beginner's
Guide to Rails Helpers].

[Rails Code (v4.2.5.2)]: https://github.com/rails/rails/tree/v4.2.5.2
[`rails` releases]: https://github.com/rails/rails/releases
[The API Documentation (v4.2.5.2)]: http://api.rubyonrails.org/v4.2.5.2/
[Ruby on Rails Guides (v4.2.5.2)]: http://guides.rubyonrails.org/v4.2.5.2/
[The Beginner's Guide to Rails Helpers]: http://mixandgo.com/blog/the-beginner-s-guide-to-rails-helpers

## Setup `dev` environment

- [Install `rvm`]

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

- [Install `ruby` version 2.2.4]

```bash
rvm install 2.2.4
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

- `rails` version 4.2.5.2 gets installed by the previous action. If
you want to start a new project at this point you should manually
install `rails` instead: `gem install rails -v 4.2.5.2`)

- [heroku] is used for the production server. To deploy, install the
[heroku toolbelt].

[Install `rvm`]: https://rvm.io/rvm/install
[Install `ruby` version 2.2.4]: https://rvm.io/rubies/installing
[Install `bundle`]: https://rvm.io/integration/bundler
[`Gemfile.lock`]: Gemfile.lock

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

## Testing

We use the testing setup suggested in the [Advanced testing setup]
section of the [Rails Tutorial Book] mentioned above. This setup
includes color enhanced representation of test results (with
[`minitest`] reporters), a `backtrace silencer` configuration and the
usage of `Guard` (with [`guard-minitest`]) for automatic test
execution of file changes.

Once everything is set up as described in the mentioned section of the
[Rails Tutorial Book], you can run `Guard` at the command line as
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
problem, just hit return again. To exit `Guard`, press `Ctrl-D`.

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

[heroku]: http://heroku.com
[heroku toolbelt]: https://toolbelt.heroku.com
[Advanced testing setup]: https://www.railstutorial.org/book/static_pages#sec-advanced_testing_setup
[Listing 3.42]: https://www.railstutorial.org/book/static_pages#code-guardfile
[`Guardfile`]: Guardfile
[`minitest`]: https://github.com/seattlerb/minitest
[`guard-minitest`]: https://github.com/guard/guard-minitest

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

To validate the user postal addresses on singup we use the
geolocalization library [Geocoder v1.2.9]. This library will allow us
also operations related to geographical relations between users,
depots and other entities.

[Geocoder v1.2.9]: https://github.com/alexreisner/geocoder/tree/v1.2.9

## Model auditing and versioning

### `paper_trail`

We use the gem [`paper_trail` (v4.0.1)] to audit changes on models.
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

[`paper_trail` (v4.0.1)]: https://github.com/airblade/paper_trail/tree/v4.0.1
[installation]: https://github.com/airblade/paper_trail/tree/v4.0.1#installation
[diffing versions]: https://github.com/airblade/paper_trail/tree/v4.0.1#diffing-versions
[metadata from controllers]: https://github.com/airblade/paper_trail/tree/v4.0.1#metadata-from-controllers
[`/app/controllers/application_controller.rb`]: /app/controllers/application_controller.rb

### `public_activity`

We use the gem [`public_activity`] [(v1.4.2)]<sup>[*](#public_activity_gem_version)</sup> to record activities in
the application.

[`public_activity`]: https://github.com/chaps-io/public_activity/tree/v1.4.1
[(v1.4.2)]: https://rubygems.org/gems/public_activity/versions/1.4.2

<a name="public_activity_gem_version">*</a>: Note that the `gem`
version in Rubygems.org is `v1.4.2` but the tag in GitHub.com is
`v1.4.1`.

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
[Ruby on Rails Security Guide]: http://guides.rubyonrails.org/v4.2.5.2/security.html
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

[RailsGuide about migrations]: http://guides.rubyonrails.org/v4.2.5.2/active_record_migrations.html#creating-a-migration
[this SO answer about creating simple vs compound indexed]: http://stackoverflow.com/a/1049392
[Efficient Use of PostgreSQL Indexes]: https://devcenter.heroku.com/articles/postgresql-indexes

## Heroku

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

### DB

To start with a fresh **dev** db on heroku do following commands:

```
heroku pg:reset --app basimilch-dev DATABASE
heroku run rake db:migrate
heroku run rake db:seed
```

To create a user with your email address, start a rails console on heroku (`heroku run rails console`) an run following command:

```
User.new(first_name: "your_first_name", last_name: "your_last_name", email: "your_email@example.com", admin: true, activation_sent_at: Time.current).save(validate: false)
```

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
