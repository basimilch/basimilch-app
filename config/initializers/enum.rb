# TODO: Find best folder to place this class.

# Allows creation of enums backed up by a string, e.g.:
#   class Severity < Enum
#     enum :LOW
#     enum :MEDIUM
#     enum :HIGH
#     enum :CRITICAL
#   end
class Enum

  # DOC: http://ruby-doc.org/core-2.4.1/Enumerable.html
  # SOURCE: http://stackoverflow.com/q/17552915
  extend Enumerable
  def self.each(&block)
    all.each(&block)
  end

  # DOC: http://ruby-doc.org/core-2.4.1/Comparable.html
  include Comparable
  def <=>(o)
    to_i <=> self.class.enum_for(o).to_i if self.class.member? o
  end

  # Class methods

  # TODO: Consider renaming :enum to :declare.
  def self.enum(name)
    unless name == name.upcase && name.is_a?(Symbol)
      raise NameError, "Enum name must be upper case symbol: #{name}", caller
    end
    if member? name
      raise NameError, "Enum #{self}::#{name} already defined", caller
    end
    # DOC: http://ruby-doc.org/core-2.2.1/Module.html#method-i-const_set
    # SOURCE: http://stackoverflow.com/a/12426510/5764181
    all << const_set(name, new(name))
  end

  # Returns effectively the same result than Enumerable#entries but without
  # going through the Enumerable#each function.
  def self.all
    @all ||= []
  end

  def self.enum_for(o)
    case o
    when self
      o
    else
      self.find{|e| e == o}
    end
  end

  # Instance methods

  def initialize(value)
    @value = value.to_s.downcase
  end

  def to_s
    "#{@value}"
  end

  def to_sym
    @value.upcase.to_sym
  end

  def to_i
    @index ||= self.class.find_index self
  end

  # Enums can be compared to themselves, to their value string or to their
  # defining symbol
  # SOURCE: http://stackoverflow.com/a/1964155
  def ==(o)
    # SOURCE: http://stackoverflow.com/a/3801609
    case o
    when String
      o.downcase == @value
    when Symbol
      o.to_s.downcase == @value
    when self.class
      o.to_s == @value
    else
      false
    end
  end
end
