require 'test_helper'

class ProductOptionTest < ActiveSupport::TestCase

  def setup
    @product_option = ProductOption.new({
        name:                       'product name',
        description:                'some description',
        size:                       0.5,
        size_unit:                  'liter',
        equivalent_in_milk_liters:  0.5,
        notes:                      'some notes'
      })
  end

  test "fixture product_options should be valid" do
    assert_valid @product_option, "Initial fixture should be valid."
    assert_valid product_options(:one),     "Fixtures should be valid."
    assert_valid product_options(:milk),    "Fixtures should be valid."
    assert_valid product_options(:yogurt),  "Fixtures should be valid."
    assert_valid product_options(:cheese),  "Fixtures should be valid."
  end

  # TODO: refactor (also in depot_test.rb) to use this method in test_helper.rb.
  #
  # # Often we test for the presence and length of a text (or string) attribute.
  # # These two tests are more concisely done with this helper.
  # def self.test_string_attribute(model_to_eval, attribute,
  #                                required: true, max_length: 255)
  #   if required
  #     test "#{attribute} should be present" do
  #       model = eval model_to_eval
  #       assert_required_attribute model, attribute
  #       model.send "#{attribute}=", nil
  #       assert_not_valid model
  #       model.send "#{attribute}=", "    "
  #       assert_not_valid model
  #     end
  #   end
  #   test "#{attribute} should not be too long" do
  #     model = eval model_to_eval
  #     model.send "#{attribute}=", "a" * (max_length + 1)
  #     assert_not_valid model
  #     model.send "#{attribute}=", "a" * (max_length)
  #     assert_valid model
  #   end
  # end
  #
  # test_string_attribute '@product_option', :name,            max_length: 10

  def self.test_attribute_present_and_not_too_long(attribute, max_length: 255)
    test "#{attribute} should be present" do
      assert_required_attribute @product_option, attribute
      @product_option.send "#{attribute}=", nil
      assert_not_valid @product_option
      @product_option.send "#{attribute}=", "    "
      assert_not_valid @product_option
    end
    test "#{attribute} should not be too long" do
      @product_option.send "#{attribute}=", "a" * (max_length + 1)
      assert_not_valid @product_option
      @product_option.send "#{attribute}=", "a" * (max_length)
      assert_valid @product_option
    end
  end

  test_attribute_present_and_not_too_long :name,            max_length: 100

  test "description should not be required" do
    assert_required_attribute @product_option, :description, required: false
    @product_option.description = nil
    assert_valid @product_option
    @product_option.description = "    "
    assert_valid @product_option
  end
  test "description should not be too long" do
    max_length = 500
    @product_option.description = "a" * (max_length + 1)
    assert_not_valid @product_option
    @product_option.description = "a" * (max_length)
    assert_valid @product_option
  end

  test "picture should not be required" do
    assert_required_attribute @product_option, :picture, required: false
  end

  test "size should be required" do
    assert_required_attribute @product_option, :size
    @product_option.size = nil
    assert_not_valid @product_option
    @product_option.size = "    "
    assert_not_valid @product_option
  end
  test "size should be valid" do
    @product_option.size = "a"
    assert_not_valid @product_option
    @product_option.size = -10
    assert_not_valid @product_option
    @product_option.size = 0
    assert_not_valid @product_option
    @product_option.size = 0.0
    assert_not_valid @product_option
    @product_option.size = 0.1
    assert_valid @product_option
    @product_option.size = 1.1
    assert_valid @product_option
    @product_option.size = 10.1
    assert_valid @product_option
    @product_option.size = 200
    assert_valid @product_option
  end

  test "size_unit should be required" do
    assert_required_attribute @product_option, :size_unit
    @product_option.size_unit = nil
    assert_not_valid @product_option
    @product_option.size_unit = "    "
    assert_not_valid @product_option
  end
  test "size_unit should be valid" do
    @product_option.size_unit = "non valid size unit"
    assert_not_valid @product_option
    @product_option.size_unit = "liter"
    assert_valid @product_option
  end

  test "equivalent_in_milk_liters should be required" do
    assert_required_attribute @product_option, :equivalent_in_milk_liters
    @product_option.equivalent_in_milk_liters = nil
    assert_not_valid @product_option
    @product_option.equivalent_in_milk_liters = "    "
    assert_not_valid @product_option
  end
  test "equivalent_in_milk_liters should be valid" do
    @product_option.equivalent_in_milk_liters = "a"
    assert_not_valid @product_option
    @product_option.equivalent_in_milk_liters = -10
    assert_not_valid @product_option
    @product_option.equivalent_in_milk_liters = 0
    assert_not_valid @product_option
    @product_option.equivalent_in_milk_liters = 0.0
    assert_not_valid @product_option
    @product_option.equivalent_in_milk_liters = 0.1
    assert_valid @product_option
    @product_option.equivalent_in_milk_liters = 1.1
    assert_valid @product_option
    @product_option.equivalent_in_milk_liters = 10.1
    assert_valid @product_option
    @product_option.equivalent_in_milk_liters = 200
    assert_valid @product_option
  end

  test "notes should not be required" do
    assert_required_attribute @product_option, :notes, required: false
    @product_option.notes = nil
    assert_valid @product_option
    @product_option.notes = "    "
    assert_valid @product_option
  end
  test "notes should not be too long" do
    max_length = 1000
    @product_option.notes = "a" * (max_length + 1)
    assert_not_valid @product_option
    @product_option.notes = "a" * (max_length)
    assert_valid @product_option
  end

  test "product must be cancelable" do
    assert Cancelable.included_in?(ProductOption)
  end
end
