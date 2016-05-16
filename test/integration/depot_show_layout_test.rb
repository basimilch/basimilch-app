require 'test_helper'

class DepotShowLayoutTest < ActionDispatch::IntegrationTest

  setup do
    @admin_user = users(:admin)
    @user       = users(:two)
    @depot      = depots(:valid)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @user.admin?
  end

  test "depot page layout for without coordinators as admin" do
    assert_layout depot: @depot, logged_in_as: @admin_user
  end

  test "depot page layout for with coordinators as admin" do
    assert_equal true, @depot.coordinators.create(user: @user).save
    assert_equal users(:two), @depot.reload.coordinators.first.user
    assert_layout depot: @depot, logged_in_as: @admin_user
  end

  test "depot page layout for with coordinator without mobile phone as admin" do
    assert_equal true, @user.update_attribute(:tel_mobile, nil)
    assert_equal true, @user.update_attribute(:tel_home, '+41441234567')
    assert_equal true, @depot.coordinators.create(user: @user).save
    assert_equal users(:two), @depot.reload.coordinators.first.user
    assert_layout depot: @depot, logged_in_as: @admin_user
  end

  test "depot page layout for with coordinator without any phone as admin" do
    assert_equal true, @user.update_attribute(:tel_mobile, nil)
    assert_equal true, @user.update_attribute(:tel_home, nil)
    assert_equal true, @user.update_attribute(:tel_office, nil)
    assert_equal true, @depot.coordinators.create(user: @user).save
    assert_equal users(:two), @depot.reload.coordinators.first.user
    assert_layout depot: @depot, logged_in_as: @admin_user
  end

  private

    def assert_layout(depot:        nil,
                      logged_in_as: nil)
      assert_protected_get depot_path(depot), login_as: logged_in_as
      assert_response :success
      assert_template 'depots/show'
      assert_select  "iframe",
                      count: 2

    end
end
