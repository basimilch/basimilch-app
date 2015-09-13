module SignupsHelper

  # Returns a string with two 3-digit numbers separated by a space.
  def rand_validation_code
    "#{rand.to_s[2..4]} #{rand.to_s[2..4]}"
  end
end
