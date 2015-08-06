# basimilch-app

Web app of the basimilch cooperative.

Done with [Ruby on Rails].

## Dev documentation

- [Rails Tutorial Book] by [Michael Hartl].
- [`rvm`] as the Ruby Version Manager.

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
  ps aux | grep spring
  pkill -9 -f spring
```

[Ruby on Rails]: http://rubyonrails.org
[Rails Tutorial Book]: https://www.railstutorial.org/book
[Michael Hartl]: http://www.michaelhartl.com
[`rvm`]: https://rvm.io
[heroku]: http://heroku.com
[heroku toolbelt]: https://toolbelt.heroku.com
[Advanced testing setup]: https://www.railstutorial.org/book/static_pages#sec-advanced_testing_setup
[Listing 3.42]: https://www.railstutorial.org/book/static_pages#code-guardfile
[`Guardfile`]: Guardfile

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
