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
    unless name == name.upcase && name.is_a?(Symbol)
      raise NameError, "Enum name must be upper case symbol: #{name}", caller
    end
    if self.valid? name
      raise NameError, "Enum #{self}::#{name} already defined", caller
    end
    # DOC: http://ruby-doc.org/core-2.2.1/Module.html#method-i-const_set
    # SOURCE: http://stackoverflow.com/a/12426510/5764181
    (@all ||= []) << const_set(name, new(name.to_s.downcase))
  end

  def self.valid?(name)
    # DOC: http://ruby-doc.org/core-2.2.1/Module.html#method-i-constant_defined
    const_defined? name.upcase.to_sym, false rescue false
  end

  def self.all
    @all
  end

  def initialize(value)
    @value = value.to_s
  end

  def to_s
    @value
  end

  # Enums can be compared to themselves or to their value string.
  # SOURCE: http://stackoverflow.com/a/1964155
  def ==(o)
    # SOURCE: http://stackoverflow.com/a/3801609
    case o
    when String
      o == @value
    when self.class
      o.to_s == @value
    else
      false
    end
  end
end
