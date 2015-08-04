# Defines the matching rules for Guard.
# Source: https://www.railstutorial.org/book/static_pages#code-guardfile

# NOTE:
#
# The Spring server is still a little quirky as of this writing, and
# sometimes Spring processes will accumulate and slow performance of
# your tests. If your tests seem to be getting unusually sluggish,
# it’s thus a good idea to inspect the system processes and kill them
# if necessary, with e.g.:
#   ps aux | grep spring
#   pkill -9 -f spring
#
# Once Guard is configured, you should open a new terminal and (as with
# the Rails server in Section 1.3.2) run it at the command line as
# follows:
#   bundle exec guard
#
# These rules are optimized for ther RailsTutorial.org, automatically
# running (for example) the integration tests when a controller is
# changed. To run all the tests, hit return at the guard> prompt. (This
# may sometimes give an error indicating a failure to connect to the
# Spring server. To fix the problem, just hit return again.)
#
# To exit Guard, press Ctrl-D.
#
# Source: https://www.railstutorial.org/book/static_pages#sec-advanced_testing_setup

guard :minitest, spring: true, all_on_start: false do
  watch(%r{^test/(.*)/?(.*)_test\.rb$})
  watch('test/test_helper.rb') { 'test' }
  watch('config/routes.rb')    { integration_tests }
  watch(%r{^app/models/(.*?)\.rb$}) do |matches|
    "test/models/#{matches[1]}_test.rb"
  end
  watch(%r{^app/controllers/(.*?)_controller\.rb$}) do |matches|
    resource_tests(matches[1])
  end
  watch(%r{^app/views/([^/]*?)/.*\.html\.erb$}) do |matches|
    ["test/controllers/#{matches[1]}_controller_test.rb"] +
    integration_tests(matches[1])
  end
  watch(%r{^app/helpers/(.*?)_helper\.rb$}) do |matches|
    integration_tests(matches[1])
  end
  watch('app/views/layouts/application.html.erb') do
    'test/integration/site_layout_test.rb'
  end
  watch('app/helpers/sessions_helper.rb') do
    integration_tests << 'test/helpers/sessions_helper_test.rb'
  end
  watch('app/controllers/sessions_controller.rb') do
    ['test/controllers/sessions_controller_test.rb',
     'test/integration/users_login_test.rb']
  end
  watch('app/controllers/account_activations_controller.rb') do
    'test/integration/users_signup_test.rb'
  end
  watch(%r{app/views/users/*}) do
    resource_tests('users') +
    ['test/integration/microposts_interface_test.rb']
  end
end

# Returns the integration tests corresponding to the given resource.
def integration_tests(resource = :all)
  if resource == :all
    Dir["test/integration/*"]
  else
    Dir["test/integration/#{resource}_*.rb"]
  end
end

# Returns the controller tests corresponding to the given resource.
def controller_test(resource)
  "test/controllers/#{resource}_controller_test.rb"
end

# Returns all tests for the given resource.
def resource_tests(resource)
  integration_tests(resource) << controller_test(resource)
end