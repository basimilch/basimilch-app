# SOURCE: http://drawingablank.me/blog/ruby-boolean-typecasting.html

class BooleanTypecastError < RuntimeError
end

class Object
  def to_b
    true
  end
  def to_b!
    res = to_b
    if res.nil?
      raise BooleanTypecastError, "Cannot cast #{self.inspect} as Boolean"
    else
      return res
    end
  end
end

class String
  def to_b
    return true   if self == true ||
                       self =~ (/^(true|t|yes|y|1)$/i)
    return false  if self == false ||
                       self.blank? ||
                       self =~ (/^(false|f|no|n|0)$/i)
  end
end

class Fixnum
  def to_b
    return true   if self == 1
    return false  if self == 0
  end
end

class TrueClass
  def to_i
    1
  end
  def to_b
    self
  end
end

class FalseClass
  def to_i
    0
  end
  def to_b
    self
  end
end

class NilClass
  def to_b
    false
  end
end
