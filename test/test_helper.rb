# Suggested by https://travis-ci.org/basimilch/basimilch-app
# SOURCE: https://github.com/codeclimate/ruby-test-reporter/blob/master/CHANGELOG.md#v100-2016-11-03
# Automatically required as dependency of gem 'codeclimate-test-reporter'.
# SOURCE: https://github.com/codeclimate/ruby-test-reporter/blob/master/CHANGELOG.md#bug-fixes-1
require 'simplecov'
SimpleCov.start

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

  def log(msg, color: :red)
    test_caller = caller.find { |caller_item| caller_item.not_match? __FILE__ }
    colored_msg = (msg.is_a?(String) ? msg : msg.inspect).send(color)
    Rails::logger.debug "#{test_caller.strip_up_to "test"}: #{colored_msg}"
  end

  def log_flash
    log "Flash messages: #{flash.each{ |i| i.to_s}}", color: :pink
  end

  def log_response_html_body
    log @response.body, color: :blue
  end

  # NOTE: Not using a constant (e.g. VALID_USER_INFO) because one (i.e. me ;)
  #       can easily forget to use '.dup' in the test (like e.g.
  #       'user_info = VALID_USER_INFO.dup'), and the reference value could be
  #       potentially modified by the tests.
  def valid_user_info_for_tests
    {
      first_name:                           'User',
      last_name:                            'Example',
      postal_address:                       'Alte Kindhauserstrasse 3',
      postal_address_supplement:            'Hof Im Basi',
      postal_code:                          '8953',
      city:                                 'Dietikon',
      tel_mobile:                           '076 111 11 11',
      email:                                'user@example.com',
      notes:                                'some_notes',
      wanted_number_of_share_certificates:  3,
      wanted_subscription:                  'no_subscription',
      terms_of_service:                     '1'
    }
  end

  # Returns true if a test user is logged in.
  #
  # NOTE: Because helper methods aren’t available in tests, we can’t use
  # the 'current_user' method, but the 'session' method is available, so
  # we use that instead. Here we use 'fixture_logged_in?' instead of
  # 'logged_in?' so that the test helper and Sessions helper methods
  # have different names, which prevents them from being mistaken for
  # each other.
  # SOURCE: https://www.railstutorial.org/book/_single-page#sec-login_upon_signup
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
    assert_difference 'PublicActivity::Activity.count', 3 do
      # One activity for each failed attempt.
      3.times do |i|
        put login_path, params: { login_code_form: {login_code: "wrong code"} }
        if i == 2
          # Last try
          follow_redirect!
          assert_template 'sessions/new'
          assert_nil session[:login_code]
        else
          assert_template 'sessions/validation'
          assert_not_equal nil, session[:login_code]
        end
        assert_select '.flash-messages .alert.alert-danger',   count: 1
      end
    end
    # Request a new code
    login_code = request_login_code(user,
                     secure_computer_acknowledged: secure_computer_acknowledged)
    # and log in properly
    assert_difference 'PublicActivity::Activity.count', 1 do
      # One activity should track the new login.
      put login_path, params: { login_code_form: {login_code: login_code} }
    end
    assert_equal true, fixture_logged_in?
  end

  def assert_required_attribute(model, attribute, required: true)
    if required
      assert model.required_attribute?(attribute),
        "Attribute #{attribute.inspect} of Model '#{model}' should be required."
    else
      assert_not model.required_attribute?(attribute),
    "Attribute #{attribute.inspect} of Model '#{model}' should NOT be required."
    end
  end

  def assert_valid(model, additional_msg = nil, valid: true)
    if valid
      assert model.valid?, "Model '#{model}' should be valid. Errors:" +
                           " #{model.errors.messages}" +
                           (additional_msg ? "\n => #{additional_msg}" : "")
    else
      assert_not model.valid?, "Model '#{model}' should NOT be valid." +
                               (additional_msg ? "\n => #{additional_msg}" : "")
    end
  end

  def assert_not_valid(model, additional_msg = nil)
    assert_valid model, additional_msg, valid: false
  end

  # Checks a protected get before and after login.
  def assert_protected_get(path, options = {})
    assert_protected options do
      get path
    end
  end

  def assert_admin_protected_get(path, options = {})
      assert_protected options.merge(admin_protected: true) do
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
    assert_not_nil user, ":login_as must be provided for 'assert_protected*'"

    unlogged_redirect = options[:unlogged_redirect]  || {}
    redirect_path     = unlogged_redirect[:path]     || login_path
    redirect_template = unlogged_redirect[:template] || 'sessions/new'
    should_have_flash = unlogged_redirect.include?(:with_flash) ?
                                          unlogged_redirect[:with_flash] : true
    admin_protected   = options.include?(:admin_protected) ?
                                          options[:admin_protected] : false
    yield
    assert_redirected_to redirect_path,
                                    "Resource is not protected by login action."
    # We display a message to ask the user to log in.
    assert_equal should_have_flash, !flash.empty?
    if integration_test?
      follow_redirect!
      assert_template redirect_template
    end
    fixture_log_in user
    if admin_protected && !user.admin?
      assert_404_error "Non-admin #{user} should not have access" do
        yield
      end
    else
      yield
    end
  end

  def assert_404_error(msg = "no 404 was raised")
    if integration_test?
      raise  "`#{__callee__}' does not work within integration tests"
    end
    assert_raises ActionController::RoutingError, msg do
      yield
    end
  end

  # SOURCE: https://github.com/alexreisner/geocoder/tree/v1.3.7#testing-apps-that-use-geocoder
  Geocoder.configure lookup: :test
  Geocoder::Lookup::Test.set_default_stub(
    [
      {
        # SOURCE: https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md#150-2018-jul-31
        # SOURCE: https://github.com/alexreisner/geocoder/issues/1258#issuecomment-359267380
        'coordinates'    => [47.3971058, 8.392147],
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
        # SOURCE: https://github.com/alexreisner/geocoder/blob/master/CHANGELOG.md#150-2018-jul-31
        # SOURCE: https://github.com/alexreisner/geocoder/issues/1258#issuecomment-359267380
        'coordinates'    => [46.9487433, 7.4538432],
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

  # SOURCE: http://stackoverflow.com/a/3377188
  # NOTE: ;deconstantize and :demodulize are Rails helpers that work like this:
  #       >> "Subscription::NEXT_UPDATE_WEEK_NUMBER".deconstantize
  #       # => "Subscription"
  #       >> "Subscription::NEXT_UPDATE_WEEK_NUMBER".demodulize
  #       # => "NEXT_UPDATE_WEEK_NUMBER"
  def with_redefined_const(const, new_val)
    _orig_val = const.constantize
    _class = const.deconstantize.constantize
    assert (_class.is_a?(Class) || _class.is_a?(Module))
    _const_name = const.demodulize.to_sym
    _class.send(:remove_const, _const_name)
    _class.const_set(_const_name, new_val)
    log "#{const} redefined to: #{const.constantize.inspect}", color: :red
    begin
      yield
    ensure
      _class.send(:remove_const, _const_name)
      _class.const_set(_const_name, _orig_val)
      log "#{const} reverted to its original value:" +
          " #{const.constantize.inspect}", color: :blue
    end
  end

  def with_env_variable(var_name, new_val)
    raise "ENV var var_name must be a String" unless var_name.is_a? String
    raise "ENV var new_val must be a String"  unless new_val.is_a? String
    if _is_originally_present = ENV.include?(var_name)
      _orig_val = ENV[var_name]
    end
    begin
      ENV[var_name] = new_val
      yield
    ensure
      if _is_originally_present
        ENV[var_name] = _orig_val
      else
        ENV.delete var_name
      end
    end
  end

  def fixture_id(fixture_label)
    ActiveRecord::FixtureSet.identify(fixture_label)
  end

  private

    # Returns true inside an integration test, and false inside other
    # tests such as controller and model tests.
    # We can tell the difference between integration tests and other
    # kinds of tests using Ruby’s convenient defined? method, which
    # returns true if its argument is defined and false otherwise. In
    # the present case, the 'post_via_redirect' method is available
    # only in integration tests.
    # SOURCE: https://www.railstutorial.org/book/_single-page#sec-testing_the_remember_me_box
    def integration_test?
      defined?(post_via_redirect)
    end

    def request_login_code(user, secure_computer_acknowledged: '1')
      assert_difference 'PublicActivity::Activity.count', 1 do
        # The action of sending of the login code email is recorded.
        assert_difference 'ActionMailer::Base.deliveries.size', 1 do
          # When the user inputs her email and sends the form with the "request
          # login code" button, one email is sent with the login code
          post login_path,
               params: {
                 session: {
                   email: user.email,
                   secure_computer_acknowledged: secure_computer_acknowledged
                 }
               }
          follow_redirect! while redirect?
        end
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



