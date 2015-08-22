require 'test_helper'

# Source: https://www.railstutorial.org/book/_single-page
#                                          #code-password_reset_integration_test

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:three)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    post password_resets_path, password_reset: { email: "foo" }
    assert_not flash.empty?
    assert_not flash[:danger].blank?, "No 'danger' alert: #{flash.inspect}"
    assert_template 'password_resets/new'
    # Valid email
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.password_reset_digest,
                     @user.reload.password_reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_not flash[:info].blank?, "No 'info' alert: #{flash.inspect}"
    assert_redirected_to login_path
    # Password reset form
    user = assigns(:user)
    # Wrong email in the link
    assert_raises ActionController::RoutingError do
      get edit_password_reset_path(user.password_reset_token, email: "bar")
    end
    # Inactive user
    assert_equal false, user.activated
    assert_raises ActionController::RoutingError do
      get edit_password_reset_path(user.password_reset_token, email: user.email)
    end
    user.toggle!(:activated)
    # Right email, wrong token
    assert_raises ActionController::RoutingError do
      get edit_password_reset_path('wrong token', email: user.email)
    end
    # Right email, right token
    get edit_password_reset_path(user.password_reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # Invalid password & confirmation
    patch password_reset_path(user.password_reset_token),
          email: user.email,
          user: { password:              "foobaz",
                  password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Empty password
    patch password_reset_path(user.password_reset_token),
          email: user.email,
          user: { password:              "",
                  password_confirmation: "" }
    assert_select 'div#error_explanation'
    assert_template 'password_resets/edit'
    # Valid password & confirmation
    patch password_reset_path(user.password_reset_token),
          email: user.email,
          user: { password:              "some_secret",
                  password_confirmation: "some_secret" }
    assert_select 'div#error_explanation', count: 0
    assert fixture_logged_in?
    assert_equal true, user.activated?
    assert_not flash.empty?
    assert_redirected_to profile_path
  end
end
