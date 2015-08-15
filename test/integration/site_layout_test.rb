require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "unlogged layout links" do
    get root_path
    assert_template 'sessions/new'
    assert_select  "a[href=?]", root_path
    # TODO: Following test is out-cmmented for mockup purposes only.
    #       Should be run when login is implemented.
    # assert_select  "a[href=?]", users_path, count: 0
    # assert_select  "a[href=?]", new_user_path, count: 0
    # Ensure there is a link to the website
    assert_select  "a[href=?]", "http://basimil.ch"
    # Ensure there is a link to the sources
    assert_select  "a[href=?]", "https://github.com/basimilch/basimilch-app"
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
