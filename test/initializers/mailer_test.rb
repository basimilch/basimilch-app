require 'test_helper'

# TODO: Should not be an Action Controller test, but a Unit Test instead.
class MailerTest < ActionController::TestCase

  setup do
    @no_address         = []
    @example_com        = ["a@example.com"]
    @example_org        = ["a@example.org"]
    @gmail_com_a_base   = ["a@gmail.com"]
    @gmail_com_a_alias  = ["a+b@gmail.com"]
    @gmail_com_a        = @gmail_com_a_base + @gmail_com_a_alias
    @gmail_com_b        = ["b@gmail.com"]
    @gmail_adresses     = @gmail_com_a + @gmail_com_b
    @all_adresses       = @example_com + @example_org + @gmail_adresses
  end

  # TODO: Separate this tests for a purely Regexp utils test, and properly
  #       test the email delivery itself with:
  #       "assert_no_difference 'ActionMailer::Base.deliveries.size' do..."

  # Test the 4 'nil' vs empty string cases
  # NOTE: Read NOTE on RecipientWhitelistInterceptor.regex_for_email_list

  test "whitelist and blacklist for emails should work 1" do
    assert_email_filter whitelist:    nil,
                        blacklist:    nil,
                        allowed_list: @all_adresses
  end

  test "whitelist and blacklist for emails should work 2" do
    assert_email_filter whitelist:    "",
                        blacklist:    nil,
                        allowed_list: @no_address
  end

  test "whitelist and blacklist for emails should work 3" do
    assert_email_filter whitelist:    nil,
                        blacklist:    "",
                        allowed_list: @all_adresses
  end

  test "whitelist and blacklist for emails should work 4" do
    assert_email_filter whitelist:    "",
                        blacklist:    "",
                        allowed_list: @no_address
  end


  # Test other combinations

  test "whitelist and blacklist for emails should work 5" do
    assert_email_filter whitelist:    "@gmail.com",
                        blacklist:    nil,
                        allowed_list: @gmail_adresses
  end

  test "whitelist and blacklist for emails should work 6" do
    assert_email_filter whitelist:    "a@gmail.com",
                        blacklist:    nil,
                        allowed_list: @gmail_com_a_base + @gmail_com_a_alias
  end

  test "whitelist and blacklist for emails should work 7" do
    assert_email_filter whitelist:    "@gmail.com",
                        blacklist:    "b@gmail.com",
                        allowed_list: @gmail_com_a_base + @gmail_com_a_alias
  end

  test "whitelist and blacklist for emails should work 8" do
    assert_email_filter whitelist:    " @gmail.com  ",
                        blacklist:    "a@gmail.com",
                        allowed_list: @gmail_com_b
  end

  test "whitelist and blacklist for emails should work 9" do
    assert_email_filter whitelist:    "@example.com  ",
                        blacklist:    nil,
                        allowed_list: @example_com
  end

  test "whitelist and blacklist for emails should work 10" do
    assert_email_filter whitelist:    "@example.com, @example.org, a@gmail.com",
                        blacklist:    nil,
                        allowed_list: @all_adresses - @gmail_com_b
  end

  test "whitelist and blacklist for emails should work 11" do
    assert_email_filter whitelist:    "@example.com,@example.org,a+b@gmail.com",
                        blacklist:    nil,
                        allowed_list: @all_adresses - @gmail_com_b
  end

  test "whitelist and blacklist for emails should work 12" do
    assert_email_filter whitelist:    "@example.com, @example.org, a@gmail.com",
                        blacklist:    "a@gmail.com",
                        allowed_list: @example_com + @example_org
  end

  test "whitelist and blacklist for emails should work 13" do
    assert_email_filter whitelist:    "@example.com, @example.org, a@gmail.com",
                        blacklist:    "a+b@gmail.com",
                        allowed_list: @example_com + @example_org
  end

  test "whitelist and blacklist for emails should work 14" do
    assert_email_filter whitelist:    nil,
                        blacklist:    "a+b@gmail.com",
                        allowed_list: @all_adresses - @gmail_com_a
  end

  test "whitelist and blacklist for emails should work 15" do
    assert_email_filter whitelist:    nil,
                        blacklist:    "@gmail.com",
                        allowed_list: @all_adresses - @gmail_adresses
  end

  test "whitelist and blacklist for emails should work 16" do
    assert_email_filter whitelist:    nil,
                        blacklist:    "@example.com, @example.org",
                        allowed_list: @gmail_adresses
  end

  # The ENV variables in Heroku might translate the spaces in non-braking
  # spaces, i.e. &nbsp. Therefore we test it here. This test is like the 16 but
  # using a non-breaking space (i.e. ALT+SPACE in a Mac computer).
  test "whitelist and blacklist for emails should work 17" do
    assert_email_filter whitelist:    nil,
                        blacklist:    "@example.com , @example.org",
                        allowed_list: @gmail_adresses
  end

  private

    def assert_email_filter(whitelist: nil, blacklist: nil, allowed_list: [])
      interceptor_class = RecipientWhitelistBlacklistInterceptor
      wl_regexp = interceptor_class.regex_for_email_list(whitelist)
      bl_regexp = interceptor_class.regex_for_email_list(blacklist)
      assert_equal allowed_list, interceptor_class.select_allowed_addresses(
                                                    @all_adresses,
                                                    whitelist_regexp: wl_regexp,
                                                    blacklist_regexp: bl_regexp
                                                  )
    end
end
