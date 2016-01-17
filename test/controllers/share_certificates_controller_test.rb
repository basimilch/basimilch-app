require 'test_helper'

class ShareCertificatesControllerTest < ActionController::TestCase

  setup do
    @admin_user = users(:one)
    @share_certificate = share_certificates(:two)
    @user = @share_certificate.user
  end

  test "non-admin user should not be able to get index" do
    assert_admin_protected_get :index, login_as: @user
  end

  test "admin should be able to get index" do
    assert_admin_protected_get :index, login_as: @admin_user
    assert_response :success
    assert_not_nil assigns(:share_certificates)
  end

  test "admin should be able to get new" do
    assert_admin_protected_get :new, login_as: @admin_user
    assert_response :success
  end

  test "admin should be able to create share_certificate" do
    assert_difference 'ShareCertificate.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, share_certificate: {
          notes:        nil,
          payed_at:     Date.today,
          returned_at:  Time.current,
          sent_at:      nil,
          user_id:      2
        }
      end
    end

    assert_redirected_to share_certificate_path(assigns(:share_certificate))
  end

  test "user for share_certificate must exist" do
    assert_no_difference 'ShareCertificate.count' do
      assert_admin_protected login_as: @admin_user do
        post :create, share_certificate: {
          notes:        nil,
          payed_at:     Date.today,
          returned_at:  Time.current,
          sent_at:      nil,
          user_id:      10000
        }
      end
    end
  end

  test "admin should be able to show share_certificate" do
    assert_admin_protected login_as: @admin_user do
      get :show, id: @share_certificate
    end
    assert_response :success
  end

  test "admin should be able to get edit" do
    assert_admin_protected login_as: @admin_user do
      get :edit, id: @share_certificate
    end
    assert_response :success
  end

  # FIX: test
  # test "admin should be able to update share_certificate" do
  #   assert_admin_protected login_as: @admin_user do
  #     patch :update, id: @share_certificate, share_certificate: {
  #       notes:        @share_certificate.notes,
  #       payed_at:     @share_certificate.payed_at,
  #       returned_at:  @share_certificate.returned_at,
  #       sent_at:      @share_certificate.sent_at,
  #       user_id:      @share_certificate.user_id
  #     }
  #     assert_redirected_to share_certificate_path(assigns(:share_certificate))
  #   end
  # end

  # FIX: test
  # test "admin should be able to destroy share_certificate" do
  #   assert_equal 1, ShareCertificate.count
  #   assert_admin_protected login_as: @admin_user do
  #     assert_difference 'ShareCertificate.count', -1 do
  #       # delete :destroy, id: @share_certificate.id
  #       delete :destroy, id: ShareCertificate.first.id
  #     end
  #     assert_redirected_to share_certificates_path
  #   end
  # end
end