require 'test_helper'

class ShareCertificateTest < ActiveSupport::TestCase

  def setup
    @user = users(:one)
    @share_certificate = @user.share_certificates.build
  end

  test "should be valid" do
    assert @share_certificate.valid?
  end

  test "user id should be present" do
    @share_certificate.user_id = nil
    assert_not @share_certificate.valid?
  end
end
