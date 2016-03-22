require 'test_helper'

# Should not be an Action Controller test, but a Unit Test instead.
class BooleanTypecastingTest < ActionController::TestCase

  test "should correctly cast to false boolean" do
    [false, nil, "", "0", "false", "f", "no", "n", "0", 0 ].each do |x|
      assert_equal false, x.to_b, "#{x.inspect} should be false"
    end
  end

  test "should correctly cast to true boolean" do
    [true, "1", "true", "t", "yes", "y", "1", 1, {}, :any_object].each do |x|
      assert_equal true, x.to_b, "#{x.inspect} should be true"
    end
  end

  test "should raise an error when casted to boolean" do
    ["2", "tru", "some string", -1, 2].each do |x|
      assert_raises ArgumentError, "#{x.inspect}.to_b should not work" do
        x.to_b
      end
    end
  end
end
