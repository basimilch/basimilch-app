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
    assert_equal true, Severity::LOW == Severity::LOW
    assert_equal true, Severity::LOW == "low"
    assert_equal true, Severity::LOW == "loW"
    assert_equal true, Severity::LOW == "LOW"
    assert_equal true, Severity::LOW == :LOW
    assert_equal true, Severity::LOW == :LOw
    assert_equal true, Severity::LOW == :low

    assert_not_equal Severity::MEDIUM, Severity::LOW
    assert_equal false, Severity::LOW == Severity::MEDIUM
    assert_equal false, Severity::LOW == "medium"
    assert_equal false, Severity::LOW == ""
    assert_equal false, Severity::LOW == nil

    assert_equal [
      Severity::LOW,
      Severity::MEDIUM,
      Severity::HIGH,
      Severity::CRITICAL
      ], Severity.all

    # It's an array, so it's sorted!
    assert_not_equal [
      Severity::MEDIUM,
      Severity::CRITICAL,
      Severity::HIGH,
      Severity::LOW
      ], Severity.all

    # NOTE: To add an enum to an existing class, you can either re-open the
    #       class or call the class method :enum. The latter is preferred.

    assert_raise NameError do
      # Severity::LOW is already defined and cannot be added
      class Severity
        enum :LOW
      end
    end
    assert_raise NameError do
      # Severity::LOW is already defined and cannot be added
      Severity.enum :LOW
    end
    assert_equal Severity::CRITICAL, Severity.all.last

    assert_raise NameError do
      # Severity::UNKNOWN is not already defined
      Severity::UNKNOWN
    end
    assert_nothing_raised do
      # Severity::UNKNOWN can be defined
      class Severity
        enum :UNKNOWN
      end
    end
    assert_equal Severity::UNKNOWN, Severity.all.last

    assert_raise NameError do
      # Severity::CUSTOM is not already defined
      Severity::CUSTOM
    end
    assert_nothing_raised do
      # Severity::CUSTOM can be defined
      Severity.enum :CUSTOM
    end
    assert_equal Severity::CUSTOM, Severity.all.last

    # The value should not be accessible from outside.
    assert_raise NoMethodError do
      Severity::LOW.value
    end
    assert_raise NoMethodError do
      Severity::LOW.value = 123
    end

    assert_equal Severity::LOW, Severity.enum_for(Severity::LOW)
    assert_equal Severity::LOW, Severity.enum_for("low")
    assert_equal Severity::LOW, Severity.enum_for("LOW")
    assert_equal Severity::LOW, Severity.enum_for(:LOW)
    assert_equal Severity::LOW, Severity.enum_for(:low)

    assert_equal nil, Severity.enum_for(:lo)
    assert_equal nil, Severity.enum_for("lo")
    assert_equal nil, Severity.enum_for("")
    assert_equal nil, Severity.enum_for(1)
    assert_equal nil, Severity.enum_for(nil)

    # The value returned by :to_s shouldn't be modifiable.
    Severity::LOW.to_s.upcase!
    assert_equal "low", Severity::LOW.to_s

    assert_equal 0, Severity::LOW.to_i
    assert_equal 1, Severity::MEDIUM.to_i
    assert_equal 2, Severity::HIGH.to_i
    assert_equal 3, Severity::CRITICAL.to_i

    # The value returned by :to_i shouldn't be modifiable.
    assert_equal 1, Severity::MEDIUM.to_i
    assert_equal 2, Severity::MEDIUM.to_i.next
    assert_equal 1, Severity::MEDIUM.to_i
    assert_equal 2, Severity::MEDIUM.to_i << 1
    assert_equal 1, Severity::MEDIUM.to_i

    # Enum class extends Enumerable

    assert_equal [
      "low",
      "medium",
      "high",
      "critical",
      "unknown",
      "custom"
      ], Severity.map(&:to_s)
    assert_equal [
      :LOW,
      :MEDIUM,
      :HIGH,
      :CRITICAL,
      :UNKNOWN,
      :CUSTOM
      ], Severity.map(&:to_sym)
    assert_equal 6, Severity.count
    assert_equal Severity.all, Severity.entries # Although :all is faster
    assert_equal Severity.all, Severity.to_a    # Although :all is faster
    assert_equal Severity.all.to_set, Severity.to_set
    assert_equal true,  Severity.member?("low")
    assert_equal true,  Severity.member?("LOW")
    assert_equal true,  Severity.member?(:LOW)
    assert_equal true,  Severity.member?(:low)
    assert_equal true,  Severity.member?(Severity::LOW)
    assert_equal false, Severity.member?("")
    assert_equal false, Severity.member?(nil)

    # With Enumerable#to_set we can compare the unsorted list of enums.
    assert_equal Severity.all.shuffle.to_set, Severity.to_set
    assert_equal [
      Severity::LOW,
      Severity::HIGH,
      Severity::CUSTOM,
      Severity::MEDIUM,
      Severity::UNKNOWN,
      Severity::CRITICAL
      ].to_set, Severity.to_set

    assert_equal Severity::HIGH,  Severity.find{|e| e.to_s.chr == "h"}

    # Enum class includes Comparable

    assert_equal Severity::LOW, Severity.min
    assert_equal Severity::CUSTOM, Severity.max

    assert_equal true,  Severity::MEDIUM <  Severity::HIGH
    assert_equal true,  Severity::MEDIUM <= Severity::HIGH
    assert_equal false, Severity::MEDIUM == Severity::HIGH
    assert_equal false, Severity::MEDIUM >= Severity::HIGH
    assert_equal false, Severity::MEDIUM >  Severity::HIGH

    assert_equal false, Severity::MEDIUM <  Severity::MEDIUM
    assert_equal true,  Severity::MEDIUM <= Severity::MEDIUM
    assert_equal true,  Severity::MEDIUM == Severity::MEDIUM
    assert_equal true,  Severity::MEDIUM >= Severity::MEDIUM
    assert_equal false, Severity::MEDIUM >  Severity::MEDIUM

    assert_equal false, Severity::MEDIUM <  Severity::LOW
    assert_equal false, Severity::MEDIUM <= Severity::LOW
    assert_equal false, Severity::MEDIUM == Severity::LOW
    assert_equal true,  Severity::MEDIUM >= Severity::LOW
    assert_equal true,  Severity::MEDIUM >  Severity::LOW

    assert_equal true,  Severity::MEDIUM <  "high"
    assert_equal true,  Severity::MEDIUM <= "high"
    assert_equal false, Severity::MEDIUM == "high"
    assert_equal false, Severity::MEDIUM >= "high"
    assert_equal false, Severity::MEDIUM >  "high"

    assert_equal false, Severity::MEDIUM <  "medium"
    assert_equal true,  Severity::MEDIUM <= "medium"
    assert_equal true,  Severity::MEDIUM == "medium"
    assert_equal true,  Severity::MEDIUM >= "medium"
    assert_equal false, Severity::MEDIUM >  "medium"

    assert_equal false, Severity::MEDIUM <  "low"
    assert_equal false, Severity::MEDIUM <= "low"
    assert_equal false, Severity::MEDIUM == "low"
    assert_equal true,  Severity::MEDIUM >= "low"
    assert_equal true,  Severity::MEDIUM >  "low"

    assert_equal true,  Severity::MEDIUM <  :HIGH
    assert_equal true,  Severity::MEDIUM <= :HIGH
    assert_equal false, Severity::MEDIUM == :HIGH
    assert_equal false, Severity::MEDIUM >= :HIGH
    assert_equal false, Severity::MEDIUM >  :HIGH

    assert_equal false, Severity::MEDIUM <  :MEDIUM
    assert_equal true,  Severity::MEDIUM <= :MEDIUM
    assert_equal true,  Severity::MEDIUM == :MEDIUM
    assert_equal true,  Severity::MEDIUM >= :MEDIUM
    assert_equal false, Severity::MEDIUM >  :MEDIUM

    assert_equal false, Severity::MEDIUM <  :LOW
    assert_equal false, Severity::MEDIUM <= :LOW
    assert_equal false, Severity::MEDIUM == :LOW
    assert_equal true,  Severity::MEDIUM >= :LOW
    assert_equal true,  Severity::MEDIUM >  :LOW

    assert_raise ArgumentError do
      Severity::LOW < nil
    end

    assert_raise ArgumentError do
      Severity::LOW < :HIG
    end

    assert_raise ArgumentError do
      Severity::LOW < "hig"
    end

    assert_raise ArgumentError do
      Severity::LOW < 1
    end
  end
end
