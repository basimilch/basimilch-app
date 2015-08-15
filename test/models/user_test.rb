require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(first_name:              "User",
                     last_name:               "Example",
                     email:                   "user@example.com")
  end

  test "fixture user should be valid" do
    assert @user.valid?, "Initial fixture user should be valid: " +
                         @user.errors.full_messages.join(", ")
  end

  test "email should be present" do
    assert @user.required_attribute?(:email)
    @user.email = "    "
    assert_not @user.valid?
  end

  test "email should not be too long" do
    domain = "@xample.com"
    # The length limit of the VARCHAR type (db representation of a String) is 255
    max_length = 255
    @user.email = "a" * (max_length - domain.length + 1) + domain
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com
                         USER@foo.COM
                         user82@500.com
                         A_US-ER@foo.bar.org
                         first.last@foo.jp
                         alice+bob@baz.ch]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com
                           user@example..com
                           user@example..
                           user_at_foo.org
                           user.name@example.
                           foo@bar_baz.com
                           foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be saved as lower case" do
    @user.email = "UsER@eXAmPle.Com"
    @user.save
    assert_equal "user@example.com", @user.reload.email
  end

  test "password and confirmation do not have to be present" do
    @user.password = @user.password_confirmation = nil
    assert @user.valid?, @user.errors.full_messages.join(", ")
    @user.password = @user.password_confirmation = ""
    assert @user.valid?, @user.errors.full_messages.join(", ")
  end

  test "user should be able to authenticate if password is not blank" do
    @user.password = @user.password_confirmation = "some_secret"
    assert @user.save, @user.errors.full_messages.join(", ")
    assert_equal false, @user.authenticate("not_right")
    assert @user.authenticate("some_secret")
  end

  test "password and confirmation cannot be only spaces" do
    @user.password = @user.password_confirmation = " " * 10
    assert_not @user.valid?
    @user.password = @user.password_confirmation = "\t" * 10
    assert_not @user.valid?
  end

  test "password and confirmation should match if both given" do
    @user.password = @user.password_confirmation = "a" * 10
    assert @user.valid?
    @user.password = "a" * 10
    @user.password_confirmation = "b" * 10
    assert_not @user.valid?
  end

  test "password must have a minimum and maximum length" do
    @user.password = @user.password_confirmation = "a" * 7
    assert_not @user.valid?
    @user.password = @user.password_confirmation = " " * 7 + "a"
    assert @user.valid?
    @user.password = @user.password_confirmation = "a" * 101
    assert_not @user.valid?
  end

  test "admin should be false by default" do
    assert_equal false, @user.admin
    assert_equal false, @user.admin?
  end

  test "first name should be present" do
    assert @user.required_attribute?(:first_name)
    @user.first_name = "     "
    assert_not @user.valid?
  end

  test "first name should not be too long" do
    @user.first_name = "a" * 41
    assert_not @user.valid?
  end

  test "last name should be present" do
    assert @user.required_attribute?(:last_name)
    @user.last_name = "     "
    assert_not @user.valid?
  end

  test "last name should not be too long" do
    @user.last_name = "a" * 41
    assert_not @user.valid?
  end

  test "postal code validation should accept valid swiss codes" do
    valid_codes = %w[0000 8004 9999]
    valid_codes.each do |valid_code|
      @user.postal_code = valid_code
      assert @user.valid?, "#{valid_code.inspect} should be valid"
    end
  end

  test "postal code validation should reject invalid swiss codes" do
    invalid_codes = %w[000 a004 99999 CH-1243 ch-1234 ch-1]
    invalid_codes.each do |invalid_code|
      @user.postal_code = invalid_code
      assert_not @user.valid?, "#{invalid_code.inspect} should be invalid"
    end
  end

  test "postal code, city and country should be present" do
    assert_not  @user.required_attribute?(:postal_address)
    assert      @user.required_attribute?(:postal_code)
    assert      @user.required_attribute?(:city)
    assert      @user.required_attribute?(:country)
    @user.postal_code = @user.city = @user.country = nil
    assert_not @user.valid?
    assert_equal 4, @user.errors.count, @user.errors.full_messages.join(", ")
  end

  test "postal code, city and country should be set by default" do
    assert_equal "8000",    @user.postal_code
    assert_equal "Zürich",  @user.city
    assert_equal "Schweiz", @user.country
  end

  test "it should be to override default postal code, city and country" do
    postal_code = "1234"
    city        = "foo"
    country     = "bar"
    @user.update_attributes(postal_code: postal_code,
                            city: city,
                            country: country)
    # Before saving they should match
    assert_equal postal_code, @user.postal_code
    assert_equal city,        @user.city
    assert_equal country,     @user.country
    # But they should still match after saving
    assert @user.save
    @user.reload
    assert_equal postal_code, @user.postal_code
    assert_equal city,        @user.city
    assert_equal country,     @user.country
  end

  test "valid phone numbers should be stored normalized" do
    valid_tels = {"+41761111111"       => ["+41761111111", "+41 76 111 11 11"],
                  "+41 76 111 11 11"   => ["+41761111111", "+41 76 111 11 11"],
                  "+41 (0) 76 1111111" => ["+41761111111", "+41 76 111 11 11"],
                  "0761111111"         => ["+41761111111", "+41 76 111 11 11"],
                  "076.111.11.11"      => ["+41761111111", "+41 76 111 11 11"],
                  "076-111-11-11"      => ["+41761111111", "+41 76 111 11 11"],
                  "+1-202-555-0110"    => ["+12025550110", "+1 (202) 555-0110"],
                  "0012025550110"      => ["+12025550110", "+1 (202) 555-0110"],
                  "+33611111111"       => ["+33611111111", "+33 6 11 11 11 11"],
                  "+33 6 11 11 11 11"  => ["+33611111111", "+33 6 11 11 11 11"],
                  "0033611111111"      => ["+33611111111", "+33 6 11 11 11 11"],
                  "0033 6 11 11 11 11" => ["+33611111111", "+33 6 11 11 11 11"]}
    valid_tels.each do |raw_tel, parsed_tels|
      normalized_tel  = parsed_tels.first
      formatted_tel   = parsed_tels.second
      # Validate all three phone nombers
      @user.tel_mobile = raw_tel
      @user.tel_home   = raw_tel
      @user.tel_office = raw_tel
      assert @user.valid?, "#{raw_tel.inspect} should be valid: " +
                           "#{@user.errors.full_messages_for(:tel_mobile)}"
      # Before saving the user to the DB, the tel is still the raw string
      assert_equal raw_tel, @user.tel_mobile
      assert @user.save
      # After saving the user to the DB, the tel should be normalized
      @user.reload
      assert_equal normalized_tel,  @user.tel_mobile
      # The tel can be retrieved as a formatted string for display
      assert_equal formatted_tel,   @user.formatted_tel(:mobile)
    end
  end

  test "the three phone numbers should be independent" do
    valid_tels = {mobile: ["076 123 45 67",         "+41 76 123 45 67"],
                  home:   ["0440101122",            "+41 44 010 11 22"],
                  office: ["+41 (0) 44 121 12 12",  "+41 44 121 12 12"]}
    valid_tels.each do |tel_type, tels|
      @user.send "tel_#{tel_type}=", tels.first
    end
    assert @user.save
    @user.reload
    valid_tels.each do |tel_type, tels|
      assert_equal @user.formatted_tel(tel_type), tels.second
    end
  end

  test "phone validation should reject invalid phone numbers" do
    invalid_tels = [
                    "a",
                    "user@example.com",
                    "+41a (0) 76 1111111",  # contains letters
                    "+41à (0) 76 1111111",  # contains letters
                    "+41ü (0) 76 1111111",  # contains letters
                    "+417611111111",        # too short
                    "+41761111111111",      # too long
                    "+41 76 11 11 11",      # too short
                    "+41 76 1111 11 11 11", # too long
                    "07611111111",          # too short
                    "0761111111111",        # too long
                    "076.111.11.11.1",      # too short
                    "076.111.11.11.111",    # too long
                    "076-111-11-11-1",      # too short
                    "076-111-11-11-111",    # too long
                    "+3361111111",          # too short
                    "+336111111111",        # too long
                    "+33 6 11 11 11 1",     # too short
                    "+33 6 11 11 11 111",   # too long
                    "+3361111111",          # too short
                    "+336111111111",        # too long
                   ]
    invalid_tels.each do |invalid_tel|
      @user.tel_mobile = invalid_tel
      assert_not @user.valid?, "#{invalid_tel.inspect} should be invalid: " +
                           "#{@user.tel_mobile.inspect} => " +
                           "#{@user.errors.full_messages_for(:tel_mobile)}"
      assert_equal nil, @user.formatted_tel(:mobile)
    end
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
    assert_not @user.authenticated?('something')
    assert_not @user.authenticated?(nil)
  end
end
