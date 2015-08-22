require 'test_helper'

class AccountActivationsControllerTest < ActionController::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "activation email sending" do
    assert_admin_protected login_as: users(:one) do
      post :create, email: users(:three).email
    end
    assert_equal users(:three), assigns(:user)
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_response :redirect
  end

  test "account activation should be allowed only to admins" do
    assert_admin_protected login_as: users(:two) do
      post :create, email: users(:three).email
    end
    assert_equal users(:three), assigns(:user)
    assert_equal 0, ActionMailer::Base.deliveries.size
  end
end
