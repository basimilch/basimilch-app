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
