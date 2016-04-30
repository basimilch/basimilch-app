require 'test_helper'

class ProductOptionsHelperTest < ActionView::TestCase

  def setup
    @product_option = product_options(:one)
  end

  test "size unit should be correctly localized" do
    size_unit = @product_option.size_unit
    assert_equal "Liter", localized_size_unit(size_unit)
    assert_equal "l", localized_size_unit(size_unit, type: :abbr)
    assert_equal "l", localized_size_unit(size_unit, type: :abbreviation)
    assert_equal "Liter (l)", localized_size_unit(size_unit, type: :label)
    assert_equal "Liter", localized_size_unit(size_unit, count: 1)
    assert_equal "Liter", localized_size_unit(size_unit, count: 2)
  end

  test "size should be properly localized" do
    assert_equal "9.99 l", localized_product_size(@product_option)
  end

  test "milk equivalence should be properly localized" do
    assert_equal "9.99 Liter Frischmilch",
                 localized_product_equivalent(@product_option)
  end
end