require 'test_helper'

class DepotTest < ActiveSupport::TestCase

  def setup
    @depot = Depot.new({
        name:                       'Depot Name',
        postal_address:             'Alte Kindhauserstrasse 3',
        postal_address_supplement:  'Hof Im Basi',
        postal_code:                '8953',
        city:                       'Dietikon',
        # country:                    '', # Setup by default, cannot be changed
        exact_map_coordinates:      '',
        # picture:                    '',
        directions:                 'foo bar',
        # delivery_day:               6,  # Setup by default
        # delivery_time:              16, # Setup by default
        opening_hours:              'from foo to bar',
        notes:                      'some notes'
      })
  end

  test "fixture depot should be valid" do
    assert_valid @depot, "Initial fixture depot should be valid."
    assert_valid depots(:valid), "Fixtures depot should be valid."
    assert_not_valid depots(:not_valid), "Fixtures depot should be valid."
  end

  def self.test_attribute_present_and_not_too_long(attribute, max_length: 255)
    test "#{attribute} should be present" do
      assert_required_attribute @depot, attribute
      @depot.send "#{attribute}=", nil
      assert_not_valid @depot
      @depot.send "#{attribute}=", "    "
      assert_not_valid @depot
    end
    test "#{attribute} should not be too long" do
      @depot.send "#{attribute}=", "a" * (max_length + 1)
      assert_not_valid @depot
      @depot.send "#{attribute}=", "a" * (max_length)
      assert_valid @depot
    end
  end

  test_attribute_present_and_not_too_long :name,            max_length: 100
  test_attribute_present_and_not_too_long :directions,      max_length: 1000
  test_attribute_present_and_not_too_long :opening_hours,   max_length: 250


  test "delivery_day should be present" do
    assert_required_attribute @depot, :delivery_day
    assert_equal 6, @depot.delivery_day # Setup by default
    @depot.delivery_day = nil
    assert_not_valid @depot
    @depot.delivery_day = "    "
    assert_not_valid @depot
  end

  test "delivery_day should be valid" do
    @depot.delivery_day = -1
    assert_not_valid @depot
    @depot.delivery_day = 7
    assert_not_valid @depot
    @depot.delivery_day = 10
    assert_not_valid @depot
    @depot.delivery_day = 0
    assert_valid @depot
    @depot.delivery_day = 6
    assert_valid @depot
  end

  test "delivery_time should be present" do
    assert_required_attribute @depot, :delivery_time
    assert_equal 16, @depot.delivery_time # Setup by default
    @depot.delivery_time = nil
    assert_not_valid @depot
    @depot.delivery_time = "    "
    assert_not_valid @depot
  end

  test "delivery_time should be valid" do
    @depot.delivery_time = -1
    assert_not_valid @depot
    @depot.delivery_time = 7
    assert_not_valid @depot
    @depot.delivery_time = 23
    assert_not_valid @depot
    @depot.delivery_time = 100
    assert_not_valid @depot
    @depot.delivery_time = 8
    assert_valid @depot
    @depot.delivery_time = 22
    assert_valid @depot
    # both numbers and string are accepted
    @depot.delivery_time = '8'
    assert_valid @depot
    @depot.delivery_time = '22'
    assert_valid @depot
  end

  test "postal address should present and be valid" do
    assert_required_attribute @depot, :postal_address
    assert_required_attribute @depot, :postal_code
    assert_required_attribute @depot, :city
    assert_required_attribute @depot, :country
    @depot.postal_address = nil
    assert_not_valid @depot
    @depot.postal_address = "    "
    assert_not_valid @depot
    @depot.postal_address = "not-existing-address"
    assert_not_valid @depot
    @depot.postal_address = "Alte Kindhauserstrasse, 3"
    assert_not_valid @depot
    @depot.postal_address = "Alte Kindhauserstrasse 3"
    assert_valid @depot
  end

  test "exact_map_coordinates should not be required" do
    assert_required_attribute @depot, :exact_map_coordinates, required: false
    @depot.exact_map_coordinates = nil
    assert_valid @depot
  end

  test "exact_map_coordinates should have a correct format" do
    @depot.exact_map_coordinates = nil
    assert_valid @depot
    @depot.exact_map_coordinates = ""
    assert_valid @depot
    @depot.exact_map_coordinates = "wrong coordinates"
    assert_not_valid @depot
    @depot.exact_map_coordinates = "47 8"
    assert_not_valid @depot
    @depot.exact_map_coordinates = "47, 8"
    assert_not_valid @depot
    @depot.exact_map_coordinates = "47.3, 8.383982"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3, 8.3"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3, 8.383982"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.395380, 8.383982"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3953800, 8.3839820"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3953800,8.3839820"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3953800 ,8.3839820"
    assert_valid @depot
    @depot.exact_map_coordinates = "47.3953800 ,  8.3839820"
    assert_valid @depot
  end

  test "saved exact_map_coordinates should have a correct format" do
    @depot.exact_map_coordinates = nil
    assert_valid @depot
    @depot.exact_map_coordinates = ""
    assert_valid @depot

    @depot.exact_map_coordinates = "47.3, 8.383982"
    assert_equal true, @depot.save
    assert_equal "47.3,8.383982", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3, 8.3"
    assert_equal true, @depot.save
    assert_equal "47.3,8.3", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3, 8.383982"
    assert_equal true, @depot.save
    assert_equal "47.3,8.383982", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.395380, 8.383982"
    assert_equal true, @depot.save
    assert_equal "47.395380,8.383982", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3953800, 8.3839820"
    assert_equal true, @depot.save
    assert_equal "47.3953800,8.3839820", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3953800,8.3839820"
    assert_equal true, @depot.save
    assert_equal "47.3953800,8.3839820", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3953800 ,8.3839820"
    assert_equal true, @depot.save
    assert_equal "47.3953800,8.3839820", @depot.reload.exact_map_coordinates

    @depot.exact_map_coordinates = "47.3953800 ,  8.3839820"
    assert_equal true, @depot.save
    assert_equal "47.3953800,8.3839820", @depot.reload.exact_map_coordinates

  end

  test "must be cancelable" do
    assert Cancelable.included_in?(DepotCoordinator)
  end
end
