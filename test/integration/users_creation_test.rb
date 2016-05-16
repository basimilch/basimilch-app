require 'test_helper'

class UsersCreationTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:admin)
    @valid_user_info = valid_user_info_for_tests
  end

  # Inspired from:
  # https://www.railstutorial.org/book/_single-page
  #                                           #sec-a_test_for_valid_submission
  test "valid user creation information" do
    assert_protected_get new_user_path, login_as: @user
    assert_template 'users/new'
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: @valid_user_info
    end
    # Check that the PublicActivity was properly recorded.
    activity = PublicActivity::Activity.last
    assert_equal 'user.create', activity.key
    assert_equal [:trackable,
                  :owner,
                  :recipient].to_set,
                 activity.parameters.keys.to_set
    assert_template 'users/show'
    assert_not flash.empty?
  end

  # Inspired from:
  # https://www.railstutorial.org/book/_single-page
  #                                           #sec-a_test_for_invalid_submission
  test "invalid user creation information" do
    assert_protected_get new_user_path, login_as: @user
    assert_template 'users/new'
    assert_no_difference 'User.count' do
      @valid_user_info[:first_name]       = ""
      @valid_user_info[:email]            = ""
      @valid_user_info[:tel_home]         = "124"
      @valid_user_info[:terms_of_service] = "0"
      @valid_user_info[:wanted_number_of_share_certificates] = nil
      post users_path, user: @valid_user_info
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation',      count: 1
    assert_select 'div#error_explanation li',   count: 7
    assert_select 'form div.field_with_errors', count: 5 * 2
  end

  test "invalid postal address in user creation information" do
    assert_protected_get new_user_path, login_as: @user
    assert_template 'users/new'
    assert_no_difference 'User.count' do
      @valid_user_info[:postal_code] = "8952"
      post users_path, user: @valid_user_info
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation',      count: 1
    assert_select 'div#error_explanation li',   count: 1
    assert_select 'form div.field_with_errors', count: 1 * 2
  end
end
