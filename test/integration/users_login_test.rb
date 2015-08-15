require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
  end

  # Inspired from: https://www.railstutorial.org/book/_single-page
  #                                                 #code-flash_persistence_test
  test "login with invalid information" do
    # Visit the login path.
    get login_path
    # Verify that the new sessions form renders properly.
    assert_template 'sessions/new'
    # Post to the sessions path with an invalid params hash.
    post login_path, session: {email: "", password: ""}
    # Verify that the new sessions form gets re-rendered,
    assert_template 'sessions/new'
    # ...and that a flash message appears.
    assert_not flash.empty?
    # Visit another page (such as the Home page).
    get root_path
    # Verify that the flash message doesn’t appear on the new page.
    assert flash.empty?
  end

  # Inspired from: https://www.railstutorial.org/book/_single-page
  #                                      #code-user_login_test_valid_information
  test "login with valid information and logout" do
    # Visit the login path.
    get login_path
    # Post valid information to the sessions path.
    post login_path, session: { email: @user.email, password: 'password' }
    assert fixture_logged_in?
    # Check the right redirect target.
    assert_redirected_to @user
    # Actually visit the target page.
    follow_redirect!
    assert_template 'users/show'
    # Verify that there is no login link.
    assert_select "a[href=?]", login_path, count: 0
    # Verify that a logout link appears
    assert_select "a[href=?]", logout_path
    # Verify that a profile link appears.
    assert_select "a[href=?]", user_path(@user)
    # Log out.
    delete logout_path
    assert_not fixture_logged_in?
    # Check the right redirect target.
    assert_redirected_to root_url
    # Simulate user clicking logout in a second window/tab of the same browser.
    delete logout_path
    # Actually visit the target page.
    follow_redirect!
    # Verify that there is no login link still.
    assert_select "a[href=?]", login_path,       count: 0
    # Verify that the logout link disppears
    assert_select "a[href=?]", logout_path,      count: 0
    # Verify that the profile link disappears.
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
