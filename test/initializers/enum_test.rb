require 'test_helper'

# TODO: Should not be an Action Controller test, but a Unit Test instead.
class EnumTest < ActionController::TestCase

  class Severity < Enum
    enum :LOW
    enum :MEDIUM
    enum :HIGH
    enum :CRITICAL
  end

  test "enum should work" do
    assert_equal Severity::LOW, Severity::LOW
    assert_equal true, Severity::LOW == "low"

    assert_not_equal Severity::MEDIUM, Severity::LOW
    assert_equal false, Severity::LOW == "medium"
    assert_equal false, Severity::LOW == ""
    assert_equal false, Severity::LOW == nil

    assert_equal true, Severity.valid?("low")
    assert_equal true, Severity.valid?("medium")

    assert_equal false, Severity.valid?("asfd")
    assert_equal false, Severity.valid?("")
    assert_equal false, Severity.valid?(nil)

    assert_raise ArgumentError do
      Severity.valid?()
    end

    assert_equal [
      Severity::LOW,
      Severity::MEDIUM,
      Severity::HIGH,
      Severity::CRITICAL,
      ], Severity.all

    # It's a sorted array
    assert_not_equal [
      Severity::MEDIUM,
      Severity::CRITICAL,
      Severity::HIGH,
      Severity::LOW,
      ], Severity.all

    assert_raise NameError do
      # Severity::LOW is already defined and cannot be added
      class Severity < Enum
        enum :LOW
      end
    end
    assert_equal Severity::CRITICAL, Severity.all.last

    assert_nothing_raised do
      # Severity::UNKNOWN is not already defined and can be added
      class Severity < Enum
        enum :UNKNOWN
      end
    end
    assert_equal Severity::UNKNOWN, Severity.all.last

    # The value should not be accessible from outside.
    assert_raise NoMethodError do
      Severity::LOW.value
    end
    assert_raise NoMethodError do
      Severity::LOW.value = 123
    end
  end
end
