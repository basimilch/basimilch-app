require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'users/index'
    assert_select  "a[href=?]", root_path
    assert_select  "a[href=?]", users_path
    assert_select  "a[href=?]", new_user_path
    # Ensure there is a link to the website
    assert_select  "a[href=?]", "http://basimil.ch"
    # Ensure there is a link to the sources
    assert_select  "a[href=?]", "https://github.com/basimilch/basimilch-app"
  end
end
