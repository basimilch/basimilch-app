# Suggested by https://travis-ci.org/basimilch/basimilch-app
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical
  # order.
  fixtures :all

  # Returns true if a test user is logged in.
  #
  # NOTE: Because helper methods aren’t available in tests, we can’t use
  # the 'current_user' method, but the 'session' method is available, so
  # we use that instead. Here we use 'fixture_logged_in?' instead of
  # 'logged_in?' so that the test helper and Sessions helper methods
  # have different names, which prevents them from being mistaken for
  # each other.
  # Source: https://www.railstutorial.org/book/_single-page
  #                                                       #sec-login_upon_signup
  def fixture_logged_in?
    !session[:user_id].nil?
  end

  def simulate_close_browser_session
    @current_user = nil
    session.delete(:user_id)
  end

  # Logs in a test user
  def fixture_log_in(user, options = {})
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    if integration_test?
      post login_path, session: {email: user.email,
                                 password: password,
                                 remember_me: remember_me}
    else
      session[:user_id] = user.id
    end
  end

  private

    # Returns true inside an integration test, and false inside other
    # tests such as controller and model tests.
    # We can tell the difference between integration tests and other
    # kinds of tests using Ruby’s convenient defined? method, which
    # returns true if its argument is defined and false otherwise. In
    # the present case, the 'post_via_redirect' method is available
    # only in integration tests.
    # Source: https://www.railstutorial.org/book/_single-page
    #                                           #sec-testing_the_remember_me_box
    def integration_test?
      defined?(post_via_redirect)
    end
end



