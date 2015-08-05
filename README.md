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

The rules in the corresponding [Guardfile] are seeded with the content
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
[Guardfile]: Guardfile
