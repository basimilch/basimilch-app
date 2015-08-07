require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(first_name:              "Example",
                     last_name:               "User",
                     email:                   "user@example.com",
                     password:                "some_secret",
                     password_confirmation:   "some_secret")
  end

  test "fixture user should be valid" do
    assert @user.valid?
  end

      # t.string   "email"
      # t.string   "password_digest"
    # t.boolean  "admin"
    # t.string   "first_name"
    # t.string   "last_name"
    # t.string   "postal_address"
    # t.string   "postal_code"
    # t.string   "city"
    # t.string   "country"
    # t.string   "tel_mobile"
    # t.string   "tel_home"
    # t.string   "tel_office"
    # t.integer  "status"
    # t.text     "notes"

  test "email should be present" do
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


  test "password and confirmation should be present" do
    @user.password = @user.password_confirmation = " " * 10
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


  test "first name should be present" do
    @user.first_name = "     "
    assert_not @user.valid?
  end

  test "first name should not be too long" do
    @user.first_name = "a" * 41
    assert_not @user.valid?
  end


  test "last name should be present" do
    @user.last_name = "     "
    assert_not @user.valid?
  end

  test "last name should not be too long" do
    @user.last_name = "a" * 41
    assert_not @user.valid?
  end
end
