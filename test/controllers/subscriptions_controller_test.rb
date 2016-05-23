require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase

  setup do
    @subscription = subscriptions(:one)

    @admin_user = users(:admin)
    @other_user = users(:two)
    @user_without_subscription = users(:three)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @other_user.admin?
  end

  # get :index

  test "non-logged-in users should not get index" do
    get :index
    assert_redirected_to login_path
  end

  test "non-admin users should not get index" do
    assert_404_error do
      assert_protected_get :index, login_as: @other_user
    end
  end

  test "admin users should get index" do
    assert_protected_get :index, login_as: @admin_user
    assert_response :success
  end

  test "show should get subscriptions with planned items" do
    assert_equal 3, Subscription.not_canceled.count
    assert_admin_protected_get :index, login_as: @admin_user
    assert_response :success
    assert_select "tr.subscription_info", 3

    get :index, view: :with_planned_items
    assert_response :success
    assert_select "tr.subscription_info", 0

    assert_difference 'SubscriptionItem.count', 2 do
      put :update, id: @subscription.id, subscription: {
          new_items_valid_from:    @subscription.next_modifiable_delivery_day,
          item_ids_and_quantities: {
            ActiveRecord::FixtureSet.identify(:milk).to_s   => 4,
            ActiveRecord::FixtureSet.identify(:yogurt).to_s => 4
          }
        }
      assert_response :redirect
      log_flash
    end
    get :index, view: :with_planned_items
    assert_response :success
    assert_select "tr.subscription_info", 1
  end

  # get :new

  test "non-logged-in users should not get new" do
    get :new
    assert_redirected_to login_path
  end

  test "non-admin users should not get new" do
    assert_404_error do
      assert_protected_get :new, login_as: @other_user
    end
  end

  test "admin users should get new" do
    assert_protected_get :new, login_as: @admin_user
    assert_response :success
  end

  # get :show

  test "non-logged-in users should not get show" do
    get :show, id: @subscription
    assert_redirected_to login_path
  end

  test "non-admin users should not get show" do
    assert_admin_protected login_as: @other_user do
      get :show, id: @subscription
    end
  end

  test "admin users should get show" do
    assert_admin_protected login_as: @admin_user do
      get :show, id: @subscription
    end
    assert_response :success
  end

  test "show should display a warning if incorrect amount of liters" do
    assert_admin_protected login_as: @admin_user do
      get :show, id: subscriptions(:one)
    end
    assert_response :success
    log_flash
    assert_equal true, flash[:warning_wrong_total_quantity].present?
  end

  test "show not should display a warning if correct amount of liters" do
    assert_admin_protected login_as: @admin_user do
      get :show, id: subscriptions(:three)
    end
    assert_response :success
    log_flash
    assert_equal false, flash[:warning_wrong_total_quantity].present?
  end

  test "show should display a warning if subscription has no users" do
    subscription_without_users = subscriptions(:three)
    assert_admin_protected login_as: @admin_user do
      get :show, id: subscription_without_users
    end
    assert_response :success
    log_flash
    # This subscription has not users.
    assert_equal true,  flash[:warning_without_users].present?
    # Add some users.
    subscription_without_users.subscriberships.create(user: User.sample)
    # Get the subscription page again
    get :show, id: subscription_without_users
    # The warning shouldn't appear now since the subscription has some users.
    assert_equal false,  flash[:warning_without_users].present?
  end

  # Because Sunday is normally 0 but in Date.commercial is 7, some errors used
  # to happed for subscriptions assigned to a depot with Sunday delivery day.
  test "show should properly display a subscription with Sunday delivery day" do
    assert_equal 6, @subscription.depot.delivery_day
    assert_admin_protected login_as: @admin_user do
      get :show, id: @subscription
    end
    assert_response :success
    put :update, id: @subscription.id, subscription: {
      depot_id: depots(:sunday_delivered).id
    }
    assert_response :redirect
    assert_redirected_to subscription_path(@subscription)
    @subscription.reload # Take into account the new depot
    assert_equal depots(:sunday_delivered), @subscription.depot
    assert_equal 0, @subscription.depot.delivery_day
    with_redefined_const 'Subscription::NEXT_UPDATE_WEEK_NUMBER', nil do
      get :show, id: @subscription
      assert_response :success
    end
    with_redefined_const 'Subscription::NEXT_UPDATE_WEEK_NUMBER', 52 do
      get :show, id: @subscription
      assert_response :success
    end
  end

  # get :edit

  test "non-logged-in users should not get edit" do
    get :edit, id: @subscription
    assert_redirected_to login_path
  end

  test "non-admin users should not get edit" do
    assert_admin_protected login_as: @other_user do
      get :edit, id: @subscription
    end
  end

  test "admin users should get edit" do
    assert_admin_protected login_as: @admin_user do
      get :edit, id: @subscription
    end
    assert_response :success
  end

  # post :create

  test "non-logged-in should not create subscription" do
    assert_no_difference 'Subscription.count' do
      post :create, subscription: {
        basic_units: 1,
        supplement_units: 0,
        depot: @subscription.depot
      }
    end
    assert_redirected_to login_path
  end

  test "non-admin should not create subscription" do
    assert_no_difference 'Subscription.count' do
      assert_admin_protected login_as: @other_user do
        post :create, subscription: {
          basic_units: 1,
          supplement_units: 0,
          depot: @subscription.depot
        }
      end
    end
  end

  test "admin should create subscription" do
    assert_difference 'Subscription.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, subscription: {
          basic_units: 1,
          supplement_units: 0,
          depot_id: @subscription.depot.id
        }
      end
      assert_response :redirect
      # After the creation we get redirected to the edit page again, to add
      # users and items.
      assert_redirected_to edit_subscription_path(assigns(:subscription))
    end

    get :edit, id: assigns(:subscription)
    assert_response :success
  end

  test "admin should create subscription without product options available" do
    assert_equal 4, ProductOption.not_canceled.count
    ProductOption.not_canceled.each { |po| po.cancel author: @admin_user }
    assert_equal 0, ProductOption.not_canceled.count

    assert_difference 'Subscription.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, subscription: {
          basic_units: 1,
          supplement_units: 0,
          depot_id: @subscription.depot.id
        }
      end
      assert_response :redirect
      # After the creation we get redirected to the edit page again, to add
      # users and items.
      assert_redirected_to edit_subscription_path(assigns(:subscription))

      get :edit, id: assigns(:subscription)
      assert_response :success
    end
  end

  # put :update, id: @subscription

  test "non-logged-in should not update subscription" do
    assert_no_difference 'Subscription.count' do
      put :update, id: @subscription.id, subscription: {
        basic_units: 1,
        supplement_units: 0,
        depot_id: @subscription.depot.id
      }
    end
    assert_redirected_to login_path
  end

  test "non-admin should not update subscription" do
    assert_no_difference 'Subscription.count' do
      assert_admin_protected login_as: @other_user do
        put :update, id: @subscription.id, subscription: {
          basic_units: 1,
          supplement_units: 0,
          depot_id: @subscription.depot.id
        }
      end
    end
  end

  test "admin should update subscription" do
    assert_no_difference 'Subscription.count' do
      assert_admin_protected login_as: @admin_user do
        put :update, id: @subscription.id, subscription: {
          basic_units: 1,
          supplement_units: 0,
          depot_id: @subscription.depot.id
        }
      end
      assert_response :redirect
      # After the update we get redirected to the show page again normally.
      assert_redirected_to subscription_path(assigns(:subscription))
    end
  end

  # get :subscription

  test "non-logged-in users should not get subscription" do
    get :subscription
    assert_redirected_to login_path
  end

  test "non-admin users should get subscription" do
    assert_protected login_as: @other_user do
      get :subscription
    end
    assert_response :success
  end

  test "non-admin users without subscription should get subscription" do
    # Although is a blank page.
    assert_protected login_as: @user_without_subscription do
      get :subscription
    end
    assert_response :success
  end

  test "admin users should get subscription" do
    assert_protected login_as: @admin_user do
      get :subscription
    end
    assert_response :success
  end

  # get :subscription_edit

  test "non-logged-in users should not get subscription_edit" do
    get :subscription_edit
    assert_redirected_to login_path
  end

  test "non-admin users should get subscription_edit" do
    assert_protected login_as: @other_user do
      get :subscription_edit
    end
    assert_response :success
  end

  test "non-admin users without subscription should get subscription_edit" do
    # Although they get redirected to the blank subscription page.
    assert_protected login_as: @user_without_subscription do
      get :subscription_edit
    end
    assert_response :redirect
    assert_redirected_to current_user_subscription_path
  end

  test "admin users should get subscription_edit" do
    assert_protected login_as: @admin_user do
      get :subscription_edit
    end
    assert_response :success
  end

  # put :subscription_update

  test "non-logged-in should not update the own subscription" do
    assert_no_difference 'Subscription.count' do
      put :subscription_update, subscription: {}
    end
    assert_redirected_to login_path
  end

  test "non-admin should update the own subscription" do
    assert_no_difference 'Subscription.count' do
      assert_protected login_as: @other_user do
        put :subscription_update, subscription: {
          new_items_valid_from: Date.tomorrow,
          item_ids_and_quantities: {
            product_options(:milk).id.to_s => '6'
          }
        }
      end
      assert_equal 'subscription.update',
                   @other_user.subscription.activities.last.key
    end
    assert_response :redirect
    # After the update we get redirected to the show page again normally.
    assert_redirected_to current_user_subscription_path
  end

  test "non-admin without subscription should update the own subscription" do
    assert_no_difference 'Subscription.count' do
      assert_protected login_as: @user_without_subscription do
        put :subscription_update, subscription: {
          new_items_valid_from: Date.tomorrow,
          item_ids_and_quantities: {
            product_options(:milk).id.to_s => '6'
          }
        }
      end
    end
    assert_response :redirect
    # After the update we get redirected to the show page again normally.
    assert_redirected_to current_user_subscription_path
  end

  test "admin should update the own subscription" do
    assert_no_difference 'Subscription.count' do
      assert_admin_protected login_as: @admin_user do
        put :subscription_update, subscription: {
          new_items_valid_from: Date.tomorrow,
          item_ids_and_quantities: {
            product_options(:milk).id.to_s => '6'
          }
        }
      end
      assert_equal 'subscription.update',
                   @admin_user.subscription.activities.last.key
    end
    assert_response :redirect
    # After the update we get redirected to the show page again normally.
    assert_redirected_to current_user_subscription_path
  end

end