require 'test_helper'

class SubscriptionItemTest < ActiveSupport::TestCase

  def setup
    @subscription = subscriptions(:one)
    @item = @subscription.subscription_items.build({
        # :subscription_id set up by the relation method :build
        product_option: product_options(:one),
        # NOTE: can also be: product_option_id: product_options(:one).id,
        # quantity:       0, # It's set up by default by the DB, see schema
        valid_since:    Date.current,
        valid_until:    nil
      })
  end

  test "fixture subscription should be valid" do
    assert_valid @item,                       "Initial fixture should be valid."
    assert_valid subscription_items(:one),    "Fixtures should be valid."
    assert_valid subscription_items(:two),    "Fixtures should be valid."
    assert_valid subscription_items(:three),  "Fixtures should be valid."
    assert_valid subscription_items(:four),   "Fixtures should be valid."
  end

  test "it should be possible to save the fixture subscription" do
    assert_equal true, @item.save
  end

  test "quantity should be present" do
    assert_required_attribute @item, :quantity
    assert_equal 0, @item.quantity # DB default, see schema
    @item.quantity = nil;    assert_not_valid @item
    @item.quantity = "    "; assert_not_valid @item
  end

  test "quantity should be valid" do
    @item.quantity = -1;   assert_not_valid  @item
    @item.quantity = 11;   assert_not_valid  @item
    @item.quantity = 100;  assert_not_valid  @item
    @item.quantity = 0;    assert_valid      @item
    @item.quantity = 10;   assert_valid      @item
  end

  test "subscription_id should be present" do
    assert_required_attribute @item, :subscription_id
    @item.subscription_id = nil;    assert_not_valid @item
    @item.subscription_id = "    "; assert_not_valid @item
  end

  test "subscription_id should be valid" do
    @item.subscription_id = -1;                     assert_not_valid  @item
    @item.subscription_id = subscriptions(:one).id; assert_valid      @item
    @item.subscription    = subscriptions(:one);    assert_valid      @item
  end

  test "subscription_id of a new subscription should be valid" do
    new_subscription = Subscription.new(depot: depots(:valid))
    assert new_subscription.save
    @item.subscription = new_subscription; assert_valid @item
  end

  test "product_option_id should be present" do
    assert_required_attribute @item, :product_option_id
    @item.product_option_id = nil;    assert_not_valid @item
    @item.product_option_id = "    "; assert_not_valid @item
  end

  test "product_option_id should be valid" do
    @item.product_option_id = -1;                       assert_not_valid  @item
    @item.product_option_id = product_options(:one).id; assert_valid      @item
    @item.product_option    = product_options(:one);    assert_valid      @item
  end

  test "product_option_id of a new product_option should be valid" do
    new_product_option = ProductOption.new(
        name:                       'new product',
        description:                'some description',
        size:                       1,
        size_unit:                  'liter',
        equivalent_in_milk_liters:  1
      )
    assert new_product_option.save
    @item.product_option = new_product_option; assert_valid @item
  end

  test "valid_since should be present" do
    assert_required_attribute @item, :valid_since
    @item.valid_since = nil;    assert_not_valid @item
    @item.valid_since = "    "; assert_not_valid @item
  end

  test "valid_since should be valid" do
    @item.valid_since = 0;            assert_not_valid  @item
    assert_equal 0, @item.valid_since
    @item.valid_since = "wrong date"; assert_not_valid  @item
    assert_equal nil, @item.valid_since
    @item.valid_since = "2016-01-01"; assert_valid      @item
    assert_equal Date.new(2016, 1, 1), @item.valid_since
  end

  test "valid_until should not be required" do
    assert_required_attribute @item, :valid_until, required: false
    @item.valid_until = nil;          assert_valid @item
    @item.valid_until = "    ";       assert_valid @item
  end

  test "valid_util should be valid" do
    @item.valid_until = 0;                           assert_not_valid   @item
    assert_equal 0, @item.valid_until
    @item.valid_until = "string will be nil-lified"; assert_valid       @item
    assert_equal nil, @item.valid_until
    @item.valid_until = "2016-01-01"; assert_valid  @item
    assert_equal Date.new(2016, 1, 1), @item.valid_until
  end
end
