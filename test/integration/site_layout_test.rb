require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:admin)
    @other_user = users(:two)
  end

  test "unlogged layout links" do
    get root_path
    assert_template 'sessions/new'
    # Ensure there is a link to the website
    assert_select  "a[href=?]", "http://basimil.ch"
    # Ensure there is a link to the sources
    assert_select  "a[href=?]", "https://github.com/basimilch/basimilch-app"
  end

  test "info global announcement should not be present if not defined" do
    assert_protected_get jobs_path, login_as: @other_user
    assert_response :success
    log_flash
    assert_select '#flash-info-global-announcement', count: 0
  end

  test "info global announcement should be present if ENV var defined" do
    with_env_variable 'INFO_GLOBAL_ANNOUNCEMENT', 'some announcement to all!' do
      assert_protected_get jobs_path, login_as: @other_user
      assert_response :success
      log_flash
      assert_select '#flash-info-global-announcement', count: 1
    end
  end

  # test "user index layout links" do
  #   get users_path
  #   assert_template 'users/index'
  #   assert_select  "a[href=?]", root_path
  #   assert_select  "a[href=?]", users_path
  #   assert_select  "a[href=?]", new_user_path
  #   # Ensure there is a link to the website
  #   assert_select  "a[href=?]", "http://basimil.ch"
  #   # Ensure there is a link to the sources
  #   assert_select  "a[href=?]", "https://github.com/basimilch/basimilch-app"
  # end
end
