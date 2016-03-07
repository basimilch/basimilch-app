require 'test_helper'

class ShareCertificateTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
    @share_certificate = @user.share_certificates.build
  end

  test "should be valid" do
    assert_valid @share_certificate
  end

  test "user id should be present" do
    @share_certificate.user_id = nil
    assert_not_valid @share_certificate
  end

  test "value_in_chf should be setup by default" do
    # The value is taken from the ENV['SHARE_CERTIFICATE_UNIT_PRICE']
    assert_equal 1, @share_certificate.value_in_chf
  end

  test "value_in_chf should be present and valid" do
    @share_certificate.value_in_chf = nil
    assert_not_valid @share_certificate
    @share_certificate.value_in_chf = 1000
    assert_not_valid @share_certificate
    @share_certificate.value_in_chf = 1
    assert_valid @share_certificate
  end
end
