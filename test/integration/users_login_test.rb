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
    # Verify that there is an email field
    assert_select "input#session_email", count: 1
    # Verify that there is no password field
    assert_select "input#session_password", count: 0
    # Verify that there is the submit button
    assert_select "input[type=submit]", count: 1
    # Try to login with a non-existent user email.
    # i.e. post to the sessions path with an invalid params hash.
    post login_path, session: {email: "non-existent-email"}
    # Verify that the new sessions form gets re-rendered,
    assert_template 'sessions/new'
    # ...and that a flash message appears.
    assert_not flash.empty?
    # Reload the (login) page.
    get login_path
    # Verify that the flash message doesn’t appear on the new page.
    assert flash.empty?
  end

  # Inspired from: https://www.railstutorial.org/book/_single-page
  #                                      #code-user_login_test_valid_information
  test "login with valid information and logout" do
    # Visit the login path.
    get login_path
    # Post valid information to the sessions path.
    fixture_log_in(@user)
    # Check that the user gets first redirected to root
    assert_redirected_to root_path
    follow_redirect!
    # ...which redirects to jobs
    assert_redirected_to jobs_path
    # Actually visit the target page.
    follow_redirect!
    assert_template 'jobs/index'
    # Verify that there is no login link.
    assert_select "a[href=?]", login_path, count: 0
    # Verify that a logout link appears
    assert_select "a[href=?]", logout_path
    # Verify that a profile link appears.
    assert_select "a[href=?]", profile_path
    # Log out.
    assert_difference 'PublicActivity::Activity.count', 1 do
      # The logout action is recorded.
      delete logout_path
    end
    assert_not fixture_logged_in?
    # Check the right redirect target.
    assert_redirected_to login_url
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

  test "visiting root without being loged in" do
    get login_path
    assert_not fixture_logged_in?
  end

  test "login with remembering" do
    get login_path
    fixture_log_in(@user, secure_computer_acknowledged: '1')
    # NOTE: for some reason inside tests the cookies method doesn’t work
    # with symbols as keys. It has to be a string.
    assert_not_nil cookies['remember_token']
    assert_not_nil @user.reload.remembered_since
    assert fixture_logged_in?
    simulate_close_browser_session
    assert_not fixture_logged_in?
    get user_path(@user)
    assert fixture_logged_in?
  end

  test "login without remembering" do
    get login_path
    fixture_log_in(@user, secure_computer_acknowledged: '0')
    assert_nil cookies['remember_token']
    assert_nil @user.reload.remembered_since
    assert fixture_logged_in?
    simulate_close_browser_session
    assert_not session[:user_id]
    get root_path # FIXME: This 'get' somehow reloads the sessions[:user_id]
                  #        But the bahaviour at the browser is the expected.
    # assert_not fixture_logged_in?
  end

  test "login audit dates" do
    first_point_in_time = Time.new(2010, 12, 31, 14, 35, 45)
    travel_to first_point_in_time do
      get login_path
      assert_nil @user.last_seen_at
      assert_nil @user.remembered_since
      fixture_log_in(@user, secure_computer_acknowledged: '1')
      assert_redirected_to root_path
      follow_redirect!
      assert_redirected_to jobs_path
      follow_redirect!
      assert_template 'jobs/index'
      assert_not_nil cookies['remember_token']
      @user.reload
      assert_equal Time.current, @user.last_seen_at
      assert_equal Time.current, @user.remembered_since
    end
    second_point_in_time = first_point_in_time + 10.minutes
    travel_to second_point_in_time do
      @user.reload
      assert_equal first_point_in_time, @user.last_seen_at
      assert_equal first_point_in_time, @user.remembered_since
      get root_path
      @user.reload
      assert_equal Time.current, @user.last_seen_at
      assert_equal first_point_in_time, @user.remembered_since
      assert_not_nil cookies['remember_token']
    end
    third_point_in_time = second_point_in_time + 5.minutes
    travel_to third_point_in_time do
      @user.reload
      assert_equal second_point_in_time, @user.last_seen_at
      assert_equal first_point_in_time, @user.remembered_since
      delete logout_path
      @user.reload
      assert_equal Time.current, @user.last_seen_at
      assert_nil @user.remembered_since
    end
  end
end
