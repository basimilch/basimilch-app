require 'test_helper'

class SubscribershipTest < ActiveSupport::TestCase

  def setup
    @s = subscriptions(:one)
    @subscribership = @s.subscriberships.build user: users(:two)
  end

  test "fixture subscription should be valid" do
    assert_valid @subscribership,
                 "Initial fixture subscribership should be valid."
    assert_valid subscriberships(:two),
                 "Fixtures subscribership should be valid."
  end

  test "subscription_id should be present" do
    assert_required_attribute @subscribership, :subscription_id
    @subscribership.subscription_id = nil;    assert_not_valid @subscribership
    @subscribership.subscription_id = "    "; assert_not_valid @subscribership
  end

  test "subscription_id should be valid" do
    @subscribership.subscription_id = -1;     assert_not_valid  @subscribership
    @subscribership.subscription_id = @s.id;  assert_valid      @subscribership
    @subscribership.subscription    = @s;     assert_valid      @subscribership
  end

  test "user_id should be present" do
    assert_required_attribute @subscribership, :user_id
    @subscribership.user_id = nil;    assert_not_valid @subscribership
    @subscribership.user_id = "    "; assert_not_valid @subscribership
  end

  test "user_id should be valid" do
    @subscribership.user_id = -1;             assert_not_valid  @subscribership
    @subscribership.user_id = users(:two).id; assert_valid      @subscribership
    @subscribership.user    = users(:two);    assert_valid      @subscribership
  end
end
