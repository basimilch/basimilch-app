require 'test_helper'

class SubscriptionLifecycleTest < ActionDispatch::IntegrationTest

  def setup
    @admin_user = users(:admin)
    @other_user = users(:two)
    @valid_subscription_basic_info = {
      name:               '',
      basic_units:        '1',
      supplement_units:   '0'
    }
  end

  test "a global notification should appear when change is possible" do
    with_redefined_const 'Subscription::NEXT_UPDATE_WEEK_NUMBER', 52 do
      assert_info_visible_in_some_pages visible_not_logged_in:  false,
                                        visible_logged_in:      true
    end
  end

  test "a global notification should not appear when change is not possible" do
    with_redefined_const 'Subscription::NEXT_UPDATE_WEEK_NUMBER', nil do
      assert_info_visible_in_some_pages visible_not_logged_in:  false,
                                        visible_logged_in:      false
    end
  end

  test "subscription items lifecycle" do
    assert_protected_get subscriptions_path, login_as: @admin_user
    assert_template 'subscriptions/index'

    create_new_subscription

    created_subscription = Subscription.last

    # Freeze the time to allow the validity dates of the items to be known.
    the_27th_of_february = Time.new(2016, 02, 27, 14, 35, 45)
    travel_to the_27th_of_february do
      # Equal to 5.5 liters
      wrong_items_list = items_info('2016-01-07',
                                    depots(:valid),
                                    milk: 3, yogurt: 5)

      # Trying to add an items list that does not add up to the equivalent number
      # of milk liters of the subscription will return the same edit page.
      assert_no_difference 'SubscriptionItem.not_canceled.count' do
        put_via_redirect subscription_path(created_subscription),
                         subscription: wrong_items_list
      end
      log_flash
      log wrong_items_list
      assert_template 'subscriptions/edit'

      assert_items [], created_subscription.reload.current_items

      assert_modification(
        created_subscription,
        '2016-01-07', depots(:valid), {milk: 2, yogurt: 4},
        count_difference: 2,
        canceled_count_difference: 0,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169"],
        current_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169"],
        expected_list_type: :current_items,
        # NOTE: The first subscription definition does not trigger a
        #       :planned_depot_change activity.
        planned_depot_change: false
      )

      # Change the composition of the same day.
      assert_modification(
        created_subscription,
        '2016-01-07', depots(:valid), {milk: 3, yogurt: 2},
        count_difference: 2,
        canceled_count_difference: 2,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - OPEN, depot: 201799169",
           "3 x Milk, 2016-01-07 - OPEN, depot: 201799169"],
        current_items_expected:
          ["2 x Yogurt, 2016-01-07 - OPEN, depot: 201799169",
           "3 x Milk, 2016-01-07 - OPEN, depot: 201799169"],
        expected_list_type: :current_items
      )

      day_depot_composition =
        ['2016-01-21', depots(:valid), {milk: 4, yogurt: 0}]
      subscription_items_expected =
        ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
         "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
         "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169",
         "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169",
         "4 x Milk, 2016-01-21 - OPEN, depot: 201799169"]
      current_items_expected =
        ["4 x Milk, 2016-01-21 - OPEN, depot: 201799169"]

      # Change the composition for a day after the same day,
      # but before the present day.
      assert_modification(
        created_subscription,
        *day_depot_composition,
        count_difference: 1,
        canceled_count_difference: 0,
        subscription_items_expected:
          subscription_items_expected,
        current_items_expected:
          current_items_expected,
        expected_list_type: :current_items
      )

      # Change updating again the same composition for the same day should
      # be a no-op.
      assert_modification(
        created_subscription,
        *day_depot_composition,
        count_difference: 0,
        canceled_count_difference: 0,
        subscription_items_expected:
          subscription_items_expected,
        current_items_expected:
          current_items_expected,
        expected_list_type: nil
      )

      # Change the composition for a day after the present day.
      assert_modification(
        created_subscription,
        '2016-03-10', depots(:valid), {milk: 0, yogurt: 8},
        count_difference: 1,
        canceled_count_difference: 0,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169",
           "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169",
           "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169",
           "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169"],
        current_items_expected:
          ["4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169"],
        expected_list_type: :planned_items
      )

      # Change the composition for the same day again.
      assert_modification(
        created_subscription,
        '2016-03-10', depots(:valid), {milk: 1, yogurt: 6},
        count_difference: 2,
        canceled_count_difference: 1,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169",
           "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169",
           "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169",
           "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "6 x Yogurt, 2016-03-10 - OPEN, depot: 201799169",
           "1 x Milk, 2016-03-10 - OPEN, depot: 201799169"],
        current_items_expected:
          ["4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169"],
        expected_list_type: :planned_items
      )

      # Change the composition for the first day again.
      assert_modification(
        created_subscription,
        '2016-01-07', depots(:valid), {cheese: 2},
        count_difference: 1,
        canceled_count_difference: 5,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169 (CANCELED)",
           "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "6 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "1 x Milk, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Cheese, 2016-01-07 - OPEN, depot: 201799169"],
        current_items_expected:
          ["2 x Cheese, 2016-01-07 - OPEN, depot: 201799169"],
        expected_list_type: :current_items
      )

      # Change the composition for a day after the present day.
      assert_modification(
        created_subscription,
        '2016-03-24', depots(:valid), {milk: 2, cheese: 1},
        count_difference: 2,
        canceled_count_difference: 0,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169 (CANCELED)",
           "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "6 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "1 x Milk, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Cheese, 2016-01-07 - 2016-03-23, depot: 201799169",
           "1 x Cheese, 2016-03-24 - OPEN, depot: 201799169",
           "2 x Milk, 2016-03-24 - OPEN, depot: 201799169"],
        current_items_expected:
          ["2 x Cheese, 2016-01-07 - 2016-03-23, depot: 201799169"],
        expected_list_type: :planned_items
      )

      # Change the depot for the same day.
      assert_modification(
        created_subscription,
        '2016-03-24', depots(:sunday_delivered), {milk: 2, cheese: 1},
        count_difference: 2,
        canceled_count_difference: 2,
        subscription_items_expected:
          ["4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
           "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169 (CANCELED)",
           "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "6 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "1 x Milk, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Cheese, 2016-01-07 - 2016-03-23, depot: 201799169",
           "1 x Cheese, 2016-03-24 - OPEN, depot: 201799169 (CANCELED)",
           "2 x Milk, 2016-03-24 - OPEN, depot: 201799169 (CANCELED)",
           "1 x Cheese, 2016-03-24 - OPEN, depot: 493240732",
           "2 x Milk, 2016-03-24 - OPEN, depot: 493240732"],
        current_items_expected:
          ["2 x Cheese, 2016-01-07 - 2016-03-23, depot: 201799169"],
        expected_list_type: :planned_items,
        planned_depot_change: true
      )

      some_day_depot_composition =
        ['2016-03-17', depots(:valid), {milk: 2, yogurt: 4}]
      some_subscription_items_expected = [
        "4 x Yogurt, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Milk, 2016-01-07 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Yogurt, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
        "3 x Milk, 2016-01-07 - 2016-01-20, depot: 201799169 (CANCELED)",
        "4 x Milk, 2016-01-21 - 2016-03-09, depot: 201799169 (CANCELED)",
        "8 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
        "6 x Yogurt, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
        "1 x Milk, 2016-03-10 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Cheese, 2016-01-07 - 2016-03-16, depot: 201799169",
        "1 x Cheese, 2016-03-24 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Milk, 2016-03-24 - OPEN, depot: 201799169 (CANCELED)",
        "1 x Cheese, 2016-03-24 - OPEN, depot: 493240732 (CANCELED)",
        "2 x Milk, 2016-03-24 - OPEN, depot: 493240732 (CANCELED)",
        "4 x Yogurt, 2016-03-17 - OPEN, depot: 201799169",
        "2 x Milk, 2016-03-17 - OPEN, depot: 201799169"
       ]
       some_current_items_expected =
        ["2 x Cheese, 2016-01-07 - 2016-03-16, depot: 201799169"]

      # Change the composition for a day after the present day, but before the
      # previous modification.
      assert_modification(created_subscription,
                          *some_day_depot_composition,
                          count_difference: 2,
                          canceled_count_difference: 2,
                          subscription_items_expected:
                            some_subscription_items_expected,
                          current_items_expected:
                            some_current_items_expected,
                          expected_list_type: :planned_items,
                          planned_depot_change: false)

      # Resending the same composition for the same day should not trigger any
      # modification.
      assert_modification(created_subscription,
                          *some_day_depot_composition,
                          count_difference: 0,
                          canceled_count_difference: 0,
                          subscription_items_expected:
                            some_subscription_items_expected,
                          current_items_expected:
                            some_current_items_expected,
                          expected_list_type: nil,
                          planned_depot_change: false)

      # Now we override the planned order to have the same composition as the
      # current one, but on another depot.

      some_day_depot_composition =
        ['2016-03-17', depots(:sunday_delivered), {cheese: 2}]
      some_subscription_items_expected.pop 2
      some_subscription_items_expected += [
        "4 x Yogurt, 2016-03-17 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Milk, 2016-03-17 - OPEN, depot: 201799169 (CANCELED)",
        "2 x Cheese, 2016-03-17 - OPEN, depot: 493240732"
       ]

      assert_modification(created_subscription,
                          *some_day_depot_composition,
                          count_difference: 1,
                          canceled_count_difference: 2,
                          subscription_items_expected:
                            some_subscription_items_expected,
                          current_items_expected:
                            some_current_items_expected,
                          expected_list_type: :planned_items,
                          planned_depot_change: true)

      # If we now we override the planned order to have the same composition
      # *and* depot as the current one, the planned order should be canceled and
      # a new one (equivalent to the current order) should be created. We could
      # also have canceled the planned order and re-open the current one, but
      # the changes would not be traceable anymore.

      some_day_depot_composition =
        ['2016-03-17', depots(:valid), {cheese: 2}]
      some_subscription_items_expected.pop 1
      some_subscription_items_expected += [
        "2 x Cheese, 2016-03-17 - OPEN, depot: 493240732 (CANCELED)",
        "2 x Cheese, 2016-03-17 - OPEN, depot: 201799169"
       ]

      assert_modification(created_subscription,
                          *some_day_depot_composition,
                          count_difference: 1,
                          canceled_count_difference: 1,
                          subscription_items_expected:
                            some_subscription_items_expected,
                          current_items_expected:
                            some_current_items_expected,
                          expected_list_type: :planned_items,
                          planned_depot_change: false)

      # If we now we re-change the order for a later date, the order of the
      # 2016-03-17 should be canceled.

      some_day_depot_composition =
        ['2016-03-24', depots(:valid), {milk: 4}]
      some_current_items_expected =
        ["2 x Cheese, 2016-01-07 - 2016-03-23, depot: 201799169"]

      # The closing date of the current items will be changed from this:
      assert_equal "2 x Cheese, 2016-01-07 - 2016-03-16, depot: 201799169",
                   some_subscription_items_expected[8]
      # to this:
      some_subscription_items_expected[8] = some_current_items_expected.first

      some_subscription_items_expected.pop 1
      some_subscription_items_expected += [
        "2 x Cheese, 2016-03-17 - OPEN, depot: 201799169 (CANCELED)",
        "4 x Milk, 2016-03-24 - OPEN, depot: 201799169",
       ]

      assert_modification(created_subscription,
                          *some_day_depot_composition,
                          count_difference: 1,
                          canceled_count_difference: 1,
                          subscription_items_expected:
                            some_subscription_items_expected,
                          current_items_expected:
                            some_current_items_expected,
                          expected_list_type: :planned_items,
                          planned_depot_change: false)


    end

    travel_to the_27th_of_february + 3.months do
      assert_items ["4 x Milk, 2016-03-24 - OPEN, depot: 201799169"],
                   Subscription.find(created_subscription.id).current_items
    end
  end

  test "subscribers lifecycle" do
    assert_protected_get subscriptions_path, login_as: @admin_user
    assert_template 'subscriptions/index'

    count = 5
    create_new_subscription count: count
    assert_equal ['user.user_login'] + ['subscription.create'] * count,
                  PublicActivity::Activity.last(count + 1).map(&:key)

    subscriptions = Subscription.last(count)
    subscription_1, subscription_2 = subscriptions

    assert_equal [true] * count, subscriptions.map(&:without_users?)
    assert_equal [true] * count, subscriptions.map(&:without_items?)

    # Since the subscription :one has users :three and :user_6 as members...
    assert_equal [:three, :user_6].map { |k| users(k).id },
                 subscriptions(:one).users.map(&:id)

    # ...they cannot be added to other subscription...
    assert_users subscription_1,
                 [:three],
                 count_difference: 0,
                 current_users_expected:
                    [],
                 # There the edit page is rendered again (no redirect) to fix
                 # the user list.
                 expected_redirect_path: nil,
                 expected_response_template: 'subscriptions/edit'

    # ...so that we cancel their subscriberships to be able to use them again...
    assert_subscribership_cancelation subscriptions(:one), :three
    assert_subscribership_cancelation subscriptions(:one), :user_6

    assert_users subscription_1,
                 [:three],
                 count_difference: 1,
                 current_users_expected:
                    ["User 3: \"Joseph The Third\" <three@example.com>"]

    assert_users subscription_1,
                 [:user_6],
                 count_difference: 1,
                 current_users_expected:
                    ["User 3: \"Joseph The Third\" <three@example.com>",
                     "User 6: \"User The 6th\" <user_6@example.com>"]

    # Adding users twice is a no-op.
    assert_users subscription_1,
                 [:three, :user_6],
                 count_difference: 0,
                 current_users_expected:
                    ["User 3: \"Joseph The Third\" <three@example.com>",
                     "User 6: \"User The 6th\" <user_6@example.com>"]

    # If a user in the list is already member of another subscription, the
    # update will fail.
    assert_users subscription_2,
                 [:three, :two],
                 count_difference: 0,
                 current_users_expected:
                    [],
                 # There the edit page is rendered again (no redirect) to fix
                 # the user list.
                 expected_redirect_path: nil,
                 expected_response_template: 'subscriptions/edit'

    assert_users subscription_2,
                 [:user_without_subscription],
                 count_difference: 1,
                 current_users_expected:
                    ["User 986848093: \"User Without Subscription\"" +
                      " <user_without_subscription@example.com>"]

    # Adding users twice is a no-op.
    assert_users subscription_2,
                 [:user_without_subscription],
                 count_difference: 0,
                 current_users_expected:
                    ["User 986848093: \"User Without Subscription\"" +
                      " <user_without_subscription@example.com>"]

    # Removing a user from a subscription makes it possible to add them to
    # another subscription.
    assert_subscribership_cancelation subscription_1, :three
    assert_subscribership_cancelation subscription_2, :user_without_subscription

    assert_users subscription_1,
                 [:user_6],
                 count_difference: 0,
                 current_users_expected:
                    ["User 6: \"User The 6th\" <user_6@example.com>"]

    assert_users subscription_2,
                 [:three, :user_without_subscription],
                 count_difference: 2,
                 current_users_expected:
                    ["User 3: \"Joseph The Third\" <three@example.com>",
                     "User 986848093: \"User Without Subscription\"" +
                      " <user_without_subscription@example.com>"]

    assert_equal [false, false] + [true] * (count - 2),
                 subscriptions.map(&:without_users?)
    assert_equal [true] * count,
                 subscriptions.map(&:without_items?)
  end

  private

    def assert_info_visible_in_some_pages(visible_not_logged_in:  false,
                                          visible_logged_in:      false)
      # Go to the login page without being logged in
      get root_path
      assert_response :success
      assert_template 'sessions/new'
      # Should we see the global flash message when not logged in?
      assert_info_subscription_updatable present: visible_not_logged_in

      # Then log in...
      assert_protected_get subscriptions_path, login_as: @other_user
      # Should we see the global flash notification?
      assert_info_subscription_updatable present: visible_logged_in

      # Now going to the root path again...
      get root_path
      # ... should redirect to the jobs page since we are logged in
      assert_response :redirect
      assert_redirected_to jobs_path
      follow_redirect!
      assert_template 'jobs/index'
      # Should we see the global flash notification?
      assert_info_subscription_updatable present: visible_logged_in
    end

    def assert_info_subscription_updatable(present: true)
      log_flash
      assert_equal present, flash[:info_subscription_updatable].present?
      assert_select ".flash-messages .alert-info", count: (present ? 1 : 0)
    end

    def create_new_subscription(count: 1)
      assert_difference 'Subscription.count', count do
        count.times do
          get new_subscription_path
          assert_template 'subscriptions/new'
          assert_difference 'Subscription.count', 1 do
            # First we create the subscription with the basic info, i.e. without
            # subscribers nor items.
            post_via_redirect subscriptions_path,
                              subscription: @valid_subscription_basic_info
          end
          # Check that the PublicActivity was properly recorded.
          activity = PublicActivity::Activity.last
          assert_equal 'subscription.create', activity.key
          created_subscription = Subscription.last
          assert_equal created_subscription.to_s, activity.parameters[:trackable]
          assert_equal @admin_user.to_s, activity.parameters[:owner]
          # Then we get directly redirected to the created subscription in edit more
          # so that we are able to add subscribers and items.
          assert_template 'subscriptions/edit'
          assert_not flash.empty?
        end
      end
    end

    def items_info(valid_from, depot, items = {})
      {
        new_items_depot_id:       depot.id,
        new_items_valid_from:     valid_from,
        item_ids_and_quantities:  Hash[items.map do | product, quantity |
          [product_options(product).id.to_s, quantity.to_s]
        end]
      }
    end

    def assert_items(expected, items)
      items_comparable = items.map do |item|
        "#{item.quantity} x #{item.product_option.name}," +
          " #{item.valid_since} - #{item.valid_until || 'OPEN'}" +
          ", depot: #{item.depot.id}" +
          "#{item.canceled? ? ' (CANCELED)' : ''}"
      end
      assert_equal expected, items_comparable
    end

    def total_liters_of_items(items)
      # SOURCE: http://tony.pitluga.com/2011/08/08/destructuring-with-ruby.html
      items.reduce(0) do | acc, (product, quantity) |
        acc += product_options(product).equivalent_in_milk_liters * quantity
      end
    end

    def assert_modification(original_subscription, date, depot, items,
                            count_difference: 0,
                            canceled_count_difference: 0,
                            subscription_items_expected: [],
                            current_items_expected: [],
                            expected_list_type: nil,
                            planned_depot_change: false)
      # Reload the subscription to be sure that the attributes are refreshed.
      subscription = Subscription.find(original_subscription.id)
      correct_items_list = items_info(date, depot, items)
      log correct_items_list
      assert_equal 4, total_liters_of_items(items), "Must be a correct list"
      assert_difference 'SubscriptionItem.not_canceled.count',
                        (count_difference - canceled_count_difference) do
        assert_difference 'SubscriptionItem.canceled.count',
                          canceled_count_difference do
          assert_difference 'SubscriptionItem.count', count_difference do
            put_via_redirect subscription_path(subscription),
                               subscription: correct_items_list
            assert_response :success
          end
        end
      end

      relevant_activity_count = count_difference +
                                  (planned_depot_change ? 1 : 0) +
                                  (expected_list_type ? 2 : 1)
      activities = PublicActivity::Activity.last(relevant_activity_count)
      log activities
      assert_equal ['subscription_item.create'] * count_difference +
                   (expected_list_type ?
                     ["subscription.#{expected_list_type}_list_modified"] :
                     [] ) +
                   (planned_depot_change ?
                     ["subscription.planned_depot_change"] :
                     [] ) +
                   ['subscription.update'],
                    activities.map(&:key)

      assert_template 'subscriptions/show'
      subscription.reload
      assert_items subscription_items_expected, subscription.subscription_items
      assert_items current_items_expected,      subscription.current_items
    end

    def user_list(*user_fixture_labels)
      { subscriber_user_ids: user_fixture_labels.map { |u| users(u).id.to_s } }
    end

    def assert_users(subscription, users,
                     count_difference: 0,
                     current_users_expected: [],
                     expected_redirect_path: subscription_path(subscription),
                     expected_response_template: 'subscriptions/show')
      # Reload the subscription to be sure that the attributes are refreshed.
      _subscription = Subscription.find(subscription.id)
      _user_list = user_list(*users)
      assert_difference 'Subscribership.not_canceled.count', count_difference do
        put subscription_path(_subscription), subscription: _user_list
      end

      if count_difference.pos?
        activities = PublicActivity::Activity.last(1 + count_difference)
        log activities
        assert_equal (['subscribership.create'] * count_difference +
                      ['subscription.update']),
                      activities.map(&:key)
      end

      if expected_redirect_path
        assert_response :redirect
        assert_redirected_to expected_redirect_path
        follow_redirect!
        assert_response :success
      else
        assert_response :success
      end
      assert_template expected_response_template
      _current_users = _subscription.reload.users.map(&:to_s)
      log _user_list
      log _current_users
      assert_equal current_users_expected, _current_users
    end

    def assert_subscribership_cancelation(subscription, user_fixture_label)
      _user = users(user_fixture_label)
      _subscribership = subscription.subscriberships.find_by(user_id: _user.id)
      log _user, color: :pink
      log _subscribership, color: :blue
      assert_difference 'Subscribership.canceled.count', 1 do
        put cancel_subscribership_path(subscription,
                                       subscribership_id: _subscribership.id)
      end
      assert_equal true, _subscribership.reload.canceled?
      activities = PublicActivity::Activity.last(2)
      log activities
      # NOTE: The order of the activities should be fixed to the reverse: first
      #       the 'subscribership.cancel' and then the 'subscription.update'.
      #       See: TODO in config/initializers/cancelable.rb
      assert_equal ['subscription.update', 'subscribership.cancel'],
                    activities.map(&:key)
    end
end
