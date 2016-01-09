# basimilch-app

[![Build Status](https://travis-ci.org/basimilch/basimilch-app.svg)](https://travis-ci.org/basimilch/basimilch-app)
[![Code Climate](https://codeclimate.com/github/basimilch/basimilch-app/badges/gpa.svg)](https://codeclimate.com/github/basimilch/basimilch-app)
[![Test Coverage](https://codeclimate.com/github/basimilch/basimilch-app/badges/coverage.svg)](https://codeclimate.com/github/basimilch/basimilch-app/coverage)

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

[Getting Started with Rails]: http://guides.rubyonrails.org/v4.2.3/getting_started.html
[Rails Tutorial]: https://www.railstutorial.org/
[Michael Hartl]: http://www.michaelhartl.com
[Rails Tutorial Book]: https://www.railstutorial.org/book/_single-page

## Dev documentation

### Ruby

- [Ruby Code (v2.2.1)]
- [Ruby 2.2.1 Standard Library Documentation]
- [Ruby Style Guide]
- [`rvm`] as the Ruby Version Manager

[Ruby Code (v2.2.1)]: https://github.com/ruby/ruby/tree/v2_2_1
[Ruby 2.2.1 Standard Library Documentation]: http://ruby-doc.org/stdlib-2.2.1/
[Ruby Style Guide]: https://github.com/bbatsov/ruby-style-guide
[`rvm`]: https://rvm.io

### Rails

- [Rails Code (v4.2.3)]
- [The API Documentation (v4.2.3)]
- [Ruby on Rails Guides (v4.2.3)]

[Rails Code (v4.2.3)]: https://github.com/rails/rails/tree/v4.2.3
[The API Documentation (v4.2.3)]: http://api.rubyonrails.org/v4.2.3/
[Ruby on Rails Guides (v4.2.3)]: http://guides.rubyonrails.org/v4.2.3/

## Environment

- Ruby version 2.2.1 (installed with `rvm install 2.2.1`)
- Rails version 4.2.3 (installed with `gem install rails -v 4.2.3`)
- [heroku] is used for the production server. To deploy, install the
[heroku toolbelt].

## Local server

The local Rails server can be started with:

``` bash
$ rails server
```

### Environment variables

You don't need to setup any environment variables by hand on your
local dev machine. Those values are automatically handled from the
file [`.env`] file by the [dotenv] gem.

[dotenv]: https://github.com/bkeepers/dotenv
[`.env`]: .env

## Testing

We use the testing setup suggested in the [Advanced testing setup]
section of the [Rails Tutorial Book] mentioned above. This setup
includes color enhanced representation of test results (with `minitest
reporters`), a `backtrace silencer` configuration and the usage of
`Guard` for automatic test execution of file changes.

Once everything is set up as described in the tutorial, you can run
`Guard` at the command line as follows:

``` bash
$ bundle exec guard
```

The rules in the corresponding [`Guardfile`] are seeded with the content
of [Listing 3.42] of the [Rails Tutorial Book]. For example, the
integration tests automatically run when a controller is changed. To
run all the tests, hit `return` at the `guard>` prompt. As mentioned
in the [Rails Tutorial Book], this may sometimes give an error
indicating a failure to connect to the Spring server. To fix the
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

## Dev DB data

Also inspired by the [Rails Tutorial Book], [section 9.3.2], we use
the _very funny_ [Faker] library :joy: to generate fake random data to
pre-populate the DB for dev purposes. This population is defined in
the file [`db/seeds.rb`]. As recommended in this article about [Rails
Migration Etiquette], to create a local DB usable for dev simply
execute:

``` bash
$ bundle exec rake db:setup
```

This command (re)creates a clean database directly from the file
[`db/schema.rb`], which is maintained by Rails itself, (i.e. `rake
db:schema:load`), and then seeds it with the demo data in the file
[`db/seeds.rb`] mentioned above (i.e. `rake db:seed`). Doing so you
prevent running all migrations from scratch (done with `rake
db:migrate:reset`)

[Rails Migration Etiquette]: http://jordanhollinger.com/2014/07/30/rails-migration-etiquette/
[section 9.3.2]: https://www.railstutorial.org/book/_single-page#sec-sample_users
[Faker]: https://github.com/stympy/faker
[`db/seeds.rb`]: db/seeds.rb
[`db/schema.rb`]: db/schema.rb

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
[Ruby on Rails Security Guide]: http://guides.rubyonrails.org/v4.2.3/security.html
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

[RailsGuide about migrations]: http://guides.rubyonrails.org/v4.2.3/active_record_migrations.html#creating-a-migration

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
