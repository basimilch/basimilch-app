# basimilch-app

[![Build Status](https://travis-ci.org/basimilch/basimilch-app.svg)](https://travis-ci.org/basimilch/basimilch-app)
[![Code Climate](https://codeclimate.com/github/basimilch/basimilch-app/badges/gpa.svg)](https://codeclimate.com/github/basimilch/basimilch-app)
[![Test Coverage](https://codeclimate.com/github/basimilch/basimilch-app/badges/coverage.svg)](https://codeclimate.com/github/basimilch/basimilch-app/coverage)

Web app of the basimilch cooperative.

Done with [Ruby on Rails].

[Ruby on Rails]: http://rubyonrails.org

## Dev documentation

- [Rails Tutorial Book] by [Michael Hartl]
- [Ruby Style Guide]
- [`rvm`] as the Ruby Version Manager

[Rails Tutorial Book]: https://www.railstutorial.org/book
[Michael Hartl]: http://www.michaelhartl.com
[Ruby Style Guide]: https://github.com/bbatsov/ruby-style-guide
[`rvm`]: https://rvm.io

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
the _very funny_ [Faker] library :joy: to generate fake random data in
the file [`db/seeds.rb`]. It can be applied with:

``` bash
$ bundle exec rake db:migrate:reset # optional to clean the DB
$ bundle exec rake db:seed          # adds 100 randon users each time
```

[section 9.3.2]: https://www.railstutorial.org/book/_single-page#sec-sample_users
[Faker]: https://github.com/stympy/faker
[`db/seeds.rb`]: db/seeds.rb

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

## Authentication

There are [lots of authentication libraries] ready to use with Ruby on
Rails. However in this application we based our implementation on the
content of [Chapter 10: "Account activation and password reset"] of
the [Rails Tutorial Book] by [Michael Hartl].

Even [`Devise`], one on the most popular authentication libraries in
this context, recommends to follow the indications of the mentioned
chapter instead of using the library itself when beginning with Rails.
In our case, this allows an easy-to-follow code for people that might
contribute to our platform and that might not be familiar with [Ruby
on Rails].

[lots of authentication libraries]: https://www.ruby-toolbox.com/categories/rails_authentication
[Chapter 10: "Account activation and password reset"]: https://www.railstutorial.org/book/account_activation_password_reset
[`Devise`]: https://github.com/plataformatec/devise#starting-with-rails

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