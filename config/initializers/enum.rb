# TODO: Find best folder to place this class.

# Allows creation of enums backed up by a string, e.g.:
#   class Severity < Enum
#     enum :LOW
#     enum :MEDIUM
#     enum :HIGH
#     enum :CRITICAL
#   end
class Enum

  def self.enum(name)
    # SOURCE: http://stackoverflow.com/a/12426510/5764181
    const_set(name, new(name.to_s.downcase))
  end

  attr_accessor :value

  def initialize(value)
    @value = value
  end

  def to_s
    @value.to_s
  end

  # Enums can be compared to themselves or to their value string.
  # SOURCE: http://stackoverflow.com/a/1964155
  def ==(o)
    # SOURCE: http://stackoverflow.com/a/3801609
    case o
    when String
      o == value
    when self.class
      o.value == value
    else
      false
    end
  end
end
