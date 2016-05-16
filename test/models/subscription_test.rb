require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

  def setup
    @subscription = Subscription.new({
        name:             nil, # It's not required
        # basic_units:      1, # It's set up by default by the DB, see schema
        # supplement_units: 0, # It's set up by default by the DB, see schema
        depot:            depots(:valid),
        notes:            nil # It's not required
      })
    @subscription_with_items = Subscription.create(depot: depots(:valid))
    @subscription_with_items.subscription_items.create(
      product_option: product_options(:milk),
      quantity: 4,
      valid_since: Date.new(2016, 1, 9)
    )
  end

  test "fixture subscription should be valid" do
    assert_valid @subscription, "Initial fixture subscription should be valid."
    assert_valid subscriptions(:one), "Fixtures subscription should be valid."
  end

  test "it should be possible to save the fixture subscription" do
    assert_equal true, @subscription.save
  end

  test "basic_units should be present" do
    assert_required_attribute @subscription, :basic_units
    assert_equal 1, @subscription.basic_units # DB default, see schema
    @subscription.basic_units = nil;    assert_not_valid @subscription
    @subscription.basic_units = "    "; assert_not_valid @subscription
  end

  test "basic_units should be valid" do
    @subscription.basic_units = -1; assert_not_valid  @subscription
    @subscription.basic_units = 0;  assert_not_valid  @subscription
    @subscription.basic_units = 5;  assert_not_valid  @subscription
    @subscription.basic_units = 10; assert_not_valid  @subscription
    @subscription.basic_units = 1;  assert_valid      @subscription
    @subscription.basic_units = 4;  assert_valid      @subscription
  end

  test "supplement_units should be present" do
    assert_required_attribute @subscription, :supplement_units
    assert_equal 0, @subscription.supplement_units # DB default, see schema
    @subscription.supplement_units = nil;    assert_not_valid @subscription
    @subscription.supplement_units = "    "; assert_not_valid @subscription
  end

  test "supplement_units should be valid" do
    @subscription.supplement_units = -1; assert_not_valid  @subscription
    @subscription.supplement_units = 4;  assert_not_valid  @subscription
    @subscription.supplement_units = 10; assert_not_valid  @subscription
    @subscription.supplement_units = 0;  assert_valid      @subscription
    @subscription.supplement_units = 3;  assert_valid      @subscription
  end

  test "depot_id should be present" do
    assert_required_attribute @subscription, :depot_id
    @subscription.depot_id = nil;    assert_not_valid @subscription
    @subscription.depot_id = "    "; assert_not_valid @subscription
  end

  test "depot_id should be valid" do
    @subscription.depot_id = -1;                assert_not_valid  @subscription
    @subscription.depot_id = depots(:valid).id; assert_valid      @subscription
    @subscription.depot    = depots(:valid);    assert_valid      @subscription
  end

  test "name should not be required" do
    assert_required_attribute @subscription, :name, required: false
    @subscription.name = nil;           assert_valid @subscription
    @subscription.name = "    ";        assert_valid @subscription
    @subscription.name = "some name";   assert_valid @subscription
  end

  test "name should not be too long" do
    @subscription.name = "a" * 101;    assert_not_valid  @subscription
    @subscription.name = "a" * 100;    assert_valid      @subscription
  end

  test "notes should not be required" do
    assert_required_attribute @subscription, :notes, required: false
    @subscription.notes = nil;          assert_valid @subscription
    @subscription.notes = "    ";       assert_valid @subscription
    @subscription.notes = "some notes"; assert_valid @subscription
  end

  test "notes should not be too long" do
    @subscription.notes = "a" * 1001;   assert_not_valid  @subscription
    @subscription.notes = "a" * 1000;   assert_valid      @subscription
  end

  test "it should be possible to update the subscription at the correct date" do
    assert_equal 21, Subscription::NEXT_UPDATE_WEEK_NUMBER # See .env.test file
    admin = users(:admin)
    user = users(:two)
    assert @subscription.current_items.blank?
    assert @subscription_with_items.current_items.present?
    delivery_day = @subscription.depot.delivery_day
    # The delivery_day of the fixture depot is Saturday.
    assert_equal 6, delivery_day
    assert_equal true, admin.admin?
    assert_equal false, user.admin?

    # TODO: For the moment, users cannot not modify their subscription even if
    #       there are no items in it. This is because the modification date
    #       would be in the future, and we have to handle the display of items
    #       when there are only planned_items, but no current_items.
    #       See: app/models/subscription.rb#can_be_updated_by?(user)

    # A couple of weeks before, it should be possible to update.
    travel_to Date.commercial(2016, 18) do
      assert_equal true,  @subscription.can_be_updated_by?(admin)
      assert_equal true,  @subscription.can_be_updated_by?(user)
      assert_equal true,  @subscription_with_items.can_be_updated_by?(user)
    end
    # The same week, it should be possible to update until Tuesday.
    travel_to Date.commercial(2016, 21, 2) do
      assert_equal true,  @subscription.can_be_updated_by?(admin)
      assert_equal true,  @subscription.can_be_updated_by?(user)
      assert_equal true,  @subscription_with_items.can_be_updated_by?(user)
    end
    # The same week, it should not be possible to update from Wednesday on.
    travel_to Date.commercial(2016, 21, 3) do
      assert_equal true,  @subscription.can_be_updated_by?(admin)
      assert_equal false, @subscription.can_be_updated_by?(user)
      assert_equal false, @subscription_with_items.can_be_updated_by?(user)
    end
    # The week after, it should not be possible to update anymore.
    travel_to Date.commercial(2016, 22) do
      assert_equal true,  @subscription.can_be_updated_by?(admin)
      assert_equal false, @subscription.can_be_updated_by?(user)
      assert_equal false, @subscription_with_items.can_be_updated_by?(user)
    end
    # If Subscription::NEXT_UPDATE_WEEK_NUMBER is not setup (i.e. is nil),
    # it should not be possible to update the subscription.
    with_redefined_const 'Subscription::NEXT_UPDATE_WEEK_NUMBER', nil do
      travel_to Date.commercial(2016, 18) do
        assert_equal true,  @subscription.can_be_updated_by?(admin)
        assert_equal false, @subscription.can_be_updated_by?(user)
        assert_equal false, @subscription_with_items.can_be_updated_by?(user)
      end
      travel_to Date.commercial(2016, 22) do
        assert_equal true,  @subscription.can_be_updated_by?(admin)
        assert_equal false, @subscription.can_be_updated_by?(user)
        assert_equal false, @subscription_with_items.can_be_updated_by?(user)
      end
    end
  end
end
