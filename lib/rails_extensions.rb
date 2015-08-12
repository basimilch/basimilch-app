# # Inspired from: http://stackoverflow.com/a/677141

class Hash

  # Returns the value given a path of keys, without failing.
  # Inspired from: http://stackoverflow.com/a/10131410
  def get(*args)
    res = self
    args.each do |k|
      if res.try('include?',k)
        res = res[k]
      else
        return nil
      end
    end
    res
  end
end


class ActiveRecord::Base

  # Source: http://stackoverflow.com/a/7830624
  # Source: http://www.keenertech.com/articles/2011/06/26/
  #                                    recipe-detecting-required-fields-in-rails
  def required_attribute?(attribute)
    self.class.validators_on(attribute).map(&:class).include?(
      ActiveRecord::Validations::PresenceValidator)
  end
end