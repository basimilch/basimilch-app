require 'test_helper'

class UsersCreationTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @valid_user_info = {first_name:     "User",
                        last_name:      "Example",
                        email:          "user@example.com",
                        postal_address: "",
                        postal_code:    "8000",
                        city:           "Zurich",
                        country:        "Schweiz",
                        tel_mobile:     "076 123 45 67",
                        tel_home:       "044 123 45 67",
                        tel_office:     "+41 (0) 22 123 45 67",
                        admin:          "0",
                        notes:          ""}
  end

  # Inspired from:
  # https://www.railstutorial.org/book/_single-page
  #                                           #sec-a_test_for_valid_submission
  test "valid user creation information" do
    ensure_protected_get new_user_path, @user
    assert_template 'users/new'
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: @valid_user_info
    end
    assert_template 'users/show'
    assert_not flash.empty?
  end

  # Inspired from:
  # https://www.railstutorial.org/book/_single-page
  #                                           #sec-a_test_for_invalid_submission
  test "invalid user creation information" do
    ensure_protected_get new_user_path, @user
    assert_template 'users/new'
    assert_no_difference 'User.count' do
      @valid_user_info[:first_name] = ""
      @valid_user_info[:email]      = ""
      @valid_user_info[:tel_home]   = "124"
      post users_path, user: @valid_user_info
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation',      count: 1
    assert_select 'div#error_explanation li',   count: 4
    assert_select 'form div.field_with_errors', count: 3 * 2
  end
end
