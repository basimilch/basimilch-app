require 'test_helper'

class SubscriptionListsTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:admin)
    @other_user = users(:two)
  end

  test "production list generation should not be accessible for non admins" do
    assert_protected_get subscription_production_list_path,
                         login_as: @other_user
    assert_response :not_found
  end

  test "depot lists generation should not be accessible for non admins" do
    assert_protected_get subscription_depot_lists_path,
                         login_as: @other_user
    assert_response :not_found
  end

  test "production list generation should be accessible for admins" do
    assert_protected_get subscription_production_list_path,
                         login_as: @admin_user
    assert_response :success
    assert_template 'subscriptions/production_list'
  end

  test "depot lists generation should be accessible for admins" do
    assert_protected_get subscription_depot_lists_path,
                         login_as: @admin_user
    assert_response :success
    assert_template 'subscriptions/depot_lists'
  end

  test "depot lists generation should work" do
    assert_protected_get depots_path,
                         login_as: @admin_user
    assert_response :success
    assert_template 'depots/index'
    # Check that we have 3 depots
    assert_select '.depots-table .depot-info', count: 3

    get subscriptions_path
    assert_response :success
    assert_template 'subscriptions/index'
    # Check that we have 3 subscriptions
    assert_select '.subscriptions-table .subscription-info', count: 3

    get users_path
    assert_response :success
    assert_template 'users/index'
    # Check that we have 8 users
    log_response_html_body
    assert_select '.users-table .user-info', count: 9

    # Check that we have 8 subscribreships (there is no page to display them)
    assert 8, Subscribership.count

    a_sunday = '2016-01-10'
    get subscription_depot_lists_path(delivery_day: a_sunday)
    assert_response :success
    assert_template 'subscriptions/depot_lists'

    assert_select '.depot-orders-table', count: 1
    assert_select '.depot-order-info', count: 2
    assert_select '.depot-orders-info.total', count: 1
    assert_select '.depot-orders-info.total', count: 1
    assert_select '.total .basic-units', count: 1, text: "2"
    assert_select '.total .supplement-units', count: 1, text: "0"
    assert_select '.total .product-option', count: 3, text: "0"
    assert_select '.total .product-option', count: 1, text: "8"

    a_monday = '2016-01-11'
    get subscription_depot_lists_path(delivery_day: a_monday)
    assert_response :success
    assert_template 'subscriptions/depot_lists'

    # No fixture depots are delivered on Monday
    assert_select '.depot-orders-table', count: 0
    assert_select '.depot-order-info', count: 0
  end
end
