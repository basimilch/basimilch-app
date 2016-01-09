# Suggested by https://travis-ci.org/basimilch/basimilch-app
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

# NOTE: Using `rake test` does correctly uses dotenv to load the .env files.
# However, when using guard to run the tests automatically on file changes the
# .env files does not seem to be loaded properly. Therefor we add this call here
# to force load the .env files.
# DOC: https://github.com/bkeepers/dotenv#note-on-load-order
Dotenv::Railtie.load

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
  def fixture_log_in(user, secure_computer_acknowledged: '1')
    unless integration_test?
      session[:user_id] = user.id
      return
    end
    assert_equal false, fixture_logged_in?
    login_code = request_login_code(user,
                     secure_computer_acknowledged: secure_computer_acknowledged)
    # Try to login with a wrong login code 3 times
    3.times do |i|
      put login_path, login_code_form: {login_code: "wrong code"}
      if i == 2
        # Last try
        follow_redirect!
        assert_template 'sessions/new'
        assert_equal nil, session[:login_code]
      else
        assert_template 'sessions/validation'
        assert_not_equal nil, session[:login_code]
      end
      assert_select '.flash-messages .alert.alert-danger',   count: 1
    end
    # Request a new code
    login_code = request_login_code(user,
                     secure_computer_acknowledged: secure_computer_acknowledged)
    # and log in properly
    put login_path, login_code_form: {login_code: login_code}
    assert_equal true, fixture_logged_in?
  end

  # Checks a protected get before and after login.
  def assert_protected_get(path, options = {})
    assert_protected options do
      get path
    end
  end

  def assert_admin_protected(options = {})
      assert_protected options.merge(admin_protected: true) do
        yield
      end
  end

  # Checks a protected path before and after login.
  def assert_protected(options = {})
    user              = options[:login_as]
    unlogged_redirect = options[:unlogged_redirect]  || {}
    redirect_path     = unlogged_redirect[:path]     || login_path
    redirect_template = unlogged_redirect[:template] || 'sessions/new'
    should_have_flash = unlogged_redirect.include?(:with_flash) ?
                                          unlogged_redirect[:with_flash] : true
    admin_protected   = options.include?(:admin_protected) ?
                                          options[:admin_protected] : false
    yield
    assert_redirected_to redirect_path
    # We display a message to ask the user to log in.
    assert_equal should_have_flash, !flash.empty?
    if integration_test?
      follow_redirect!
      assert_template redirect_template
    end
    fixture_log_in user
    if admin_protected && !user.admin?
      assert_404_error do
        yield
      end
    else
      yield
    end
  end

  def assert_404_error
    assert_raises ActionController::RoutingError do
      yield
    end
  end

  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.2.9
  #                                              #testing-apps-that-use-geocoder
  Geocoder.configure lookup: :test
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        'latitude'       => 47.3971058,
        'longitude'      => 8.392147,
        'full_address'   => "Alte Kindhauserstrasse 3, 8953 Dietikon, Switzerland",
        'route'          => "Alte Kindhauserstrasse",
        'street_number'  => "3",
        'city'           => "Dietikon",
        'postal_code'    => "8953",
        'state_province' => "Zürich",
        'country'        => "Schweiz"
      }
    ]
  )
  Geocoder::Lookup::Test.add_stub(
    "Postgasse 1, 3011, Bern, Schweiz", [
      {
        'latitude'       => 46.9487433,
        'longitude'      => 7.4538432,
        'address'        => "Postgasse 1, 3011 Bern, Switzerland",
        'route'          => "Postgasse",
        'street_number'  => "1",
        'city'           => "Bern",
        'postal_code'    => "3011",
        'state_province' => "Bern",
        'country'        => "Schweiz"
      }
    ]
  )

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

    def request_login_code(user, secure_computer_acknowledged: '1')
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        # When the user inputs her email and sends the form with the "request
        # login code" button, one email is sent with the login code
        post_via_redirect(
          login_path,
          session: {
            email: user.email,
            secure_computer_acknowledged: secure_computer_acknowledged
          }
        )
      end
      # ...and the login-code screen appears
      assert_template 'sessions/validation'
      # ...and the login-code appears (secured) in the session cookie
      assert_not_equal nil, session[:login_code]
      # ...and there is a field to input the code received per email
      assert_select "#login_code_form_login_code",   count: 1
      # SOURCE: http://stackoverflow.com/a/3517684
      login_code_email = ActionMailer::Base.deliveries.last
      assert_match user.email, login_code_email[:to].value
      # Retrieve the login code from the email
      login_code = login_code_email.body.to_s.scan(/login\/\d{6}/).first.number
      # The hash of the login code is encrypted and securely stored in the
      # session cookie.
      assert_equal true,
                   session[:login_code].is_secure_temp_digest_for?(login_code)
      return login_code
    end
end



