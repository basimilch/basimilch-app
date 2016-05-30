require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(valid_user_info_for_tests)
  end

  test "fixture user should be valid" do
    assert_valid @user, "Initial fixture user should be valid."
  end

  test "status should be valid if present" do
    assert_required_attribute @user, :status, required: false
    @user.status = nil
    assert_valid @user
    @user.status = User::Status::WAITING_LIST
    assert_valid @user
    @user.status = "some thing else"
    assert_not_valid @user
  end

  test "email should be present" do
    assert_required_attribute @user, :email
    @user.email = nil
    assert_not_valid @user
    @user.email = "    "
    assert_not_valid @user
  end

  test "email should not be too long" do
    domain = "@xample.com"
    # The length limit of the VARCHAR type (db representation of a String) is 255
    max_length = 255
    @user.email = "a" * (max_length - domain.length + 1) + domain
    assert_not_valid @user
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
      assert_valid @user, "#{valid_address.inspect} should be valid"
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
      assert_not_valid @user, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not_valid duplicate_user
  end

  test "email should be saved as lower case" do
    @user.email = "UsER@eXAmPle.Com"
    @user.save
    assert_equal "user@example.com", @user.reload.email
  end

  test "admin should be false by default" do
    assert_equal false, @user.admin
    assert_equal false, @user.admin?
  end

  test "first name should be present" do
    assert_required_attribute @user, :first_name
    @user.first_name = "     "
    assert_not_valid @user
  end

  test "first name should not be too long" do
    @user.first_name = "a" * 41
    assert_not_valid @user
  end

  test "each word in first name should be capitalized on validation" do
    @user.first_name = "aaaa bbb"
    assert_valid @user
    assert_equal "Aaaa Bbb", @user.first_name
  end

  test "last name should be present" do
    assert_required_attribute @user, :last_name
    @user.last_name = "     "
    assert_not_valid @user
  end

  test "last name should not be too long" do
    @user.last_name = "a" * 41
    assert_not_valid @user
  end

  test "each word in last name should be capitalized on validation" do
    @user.last_name = "bbbbb ccc"
    assert_valid @user
    assert_equal "Bbbbb Ccc", @user.last_name
  end

  test "user must be able to have an address" do
    assert HasPostalAddress.included_in?(User)
  end

  test "postal code validation should reject invalid swiss codes" do
    invalid_codes = %w[0000 000 a004 99999 CH-1243 ch-1234 ch-1]
    invalid_codes.each do |invalid_code|
      @user.postal_code = invalid_code
      assert_not_valid @user, "#{invalid_code.inspect} should be invalid"
    end
  end

  test "postal adress, postal code, city and country should be present" do
    assert_required_attribute @user, :postal_address
    assert_required_attribute @user, :postal_code
    assert_required_attribute @user, :city
    assert_required_attribute @user, :country
    @user.postal_code = @user.city = @user.country = nil
    assert_not_valid @user
    assert_equal 5, @user.errors.count, @user.errors.full_messages.join(", ")
  end

  test "country should be set by default" do
    assert_equal "Schweiz", @user.country
  end

  test "it should be possible to override default postal code, city and country
        with real values" do
    postal_address  = "Postgasse 1"
    postal_code     = "3011"
    city            = "Bern"
    @user.update_attributes(postal_address: postal_address,
                            postal_code:    postal_code,
                            city:           city)
    # Before saving they should match
    assert_equal postal_address,  @user.postal_address
    assert_equal postal_code,     @user.postal_code
    assert_equal city,            @user.city
    # But they should still match after saving
    assert @user.save, "Some unexpected errors: #{@user.errors.full_messages}"
    @user.reload
    assert_equal postal_address,  @user.postal_address
    assert_equal postal_code,     @user.postal_code
    assert_equal city,            @user.city
  end

  test "adding a postal address supplement should be valid" do
    @user.postal_address_supplement = "c/o Somebody"
    assert_valid @user, "User with postal address suppl. should be valid."
  end

  test "postal address supplement should be max 50 chars long" do
    @user.postal_address_supplement = "a" * 50
    assert_valid @user
    @user.postal_address_supplement = "a" * 51
    assert_not_valid @user, "Postal address suppl. should be max 50 char long."
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
      # Validate all three phone numbers
      @user.tel_mobile = raw_tel
      @user.tel_home   = raw_tel
      @user.tel_office = raw_tel
      assert_valid @user, "#{raw_tel.inspect} should be valid."
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
      assert_not_valid @user, "#{invalid_tel.inspect} should be invalid: " +
                           "#{@user.tel_mobile.inspect}"
      assert_equal nil, @user.formatted_tel(:mobile)
    end
  end

  test "at least one phone number should be present" do
    @user.tel_mobile = nil
    assert_not_valid @user
    @user.tel_home = "044 111 11 11"
    assert_valid @user
    @user.tel_home = nil
    @user.tel_office = "044 222 22 22"
    assert_valid @user
    @user.tel_mobile = @user.tel_home = @user.tel_office = nil
    assert_not_valid @user
  end

  test "it should be possible to get formatted swiss tels" do
    assert_equal '076 111 11 11', @user.tel_mobile
    assert_equal '+41 76 111 11 11', @user.tel_mobile_formatted
    assert_equal '076 111 11 11', @user.tel_mobile_formatted_national
    assert @user.save
    assert_equal '+41761111111', @user.reload.tel_mobile
    assert_equal '+41 76 111 11 11', @user.tel_mobile_formatted
    assert_equal '076 111 11 11', @user.tel_mobile_formatted_national
  end

  test "it should be possible to get formatted non-swiss tels" do
    assert_equal '076 111 11 11', @user.tel_mobile
    @user.tel_mobile = '+49 76 1 1 1 1 1 1 1'
    assert_equal '+49 76 1 1 1 1 1 1 1', @user.tel_mobile
    assert_equal '+49 761 111 111', @user.tel_mobile_formatted
    assert_equal '+49 761 111 111', @user.tel_mobile_formatted_national
    assert @user.save
    assert_equal '+49761111111', @user.reload.tel_mobile
    assert_equal '+49 761 111 111', @user.tel_mobile_formatted
    assert_equal '+49 761 111 111', @user.tel_mobile_formatted_national
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
    assert_not @user.authenticated?(:remember, 'something')
    assert_not @user.authenticated?(:remember, nil)
  end

  test "wanted_number_of_share_certificates should be present and valid" do
    assert_required_attribute @user, :wanted_number_of_share_certificates
    @user.wanted_number_of_share_certificates = -1
    assert_not_valid @user
    @user.wanted_number_of_share_certificates = 1
    assert_valid @user
  end

  test "wanted_subscription should be present and valid" do
    assert_required_attribute @user, :wanted_subscription
    @user.wanted_subscription = 'blahblah'
    assert_not_valid @user
    @user.wanted_subscription = 'no_subscription'
    assert_valid @user
  end

  test "terms_of_service should be present and accepted" do
    assert_required_attribute @user, :terms_of_service
    @user.terms_of_service = "0"
    assert_not_valid @user
    @user.terms_of_service = "1"
    assert_valid @user
  end

  test "sign-up specific fields are only required on signup" do
    # NOTE: 'assign_attributes' does not update the DB,
    #        but 'update_attributes' does.
    @user.assign_attributes(
        wanted_number_of_share_certificates: nil,
        wanted_subscription: nil,
        terms_of_service: nil
      )
    assert_not_valid @user
    @user.assign_attributes(
        wanted_number_of_share_certificates: 1,
        wanted_subscription: 'no_subscription',
        terms_of_service: '1'
      )
    assert_valid @user
    assert_equal nil, @user.id
    assert @user.save
    assert @user.id.is_a? Integer
    @user.reload
    @user.assign_attributes(
        wanted_number_of_share_certificates: nil,
        wanted_subscription: nil,
        terms_of_service: nil
      )
    assert_valid @user
    assert @user.destroy
  end

  test "count of jobs done this year should work" do
    assert_equal 0, users(:admin).count_of_jobs_done_this_year
    assert_equal 2, users(:two).count_of_jobs_done_this_year
    assert_equal 1, users(:three).count_of_jobs_done_this_year
  end
end
