require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:admin)
    @normal_user = users(:two)
  end

  test "admins should see profile notes" do
    assert_equal true,  @admin.admin?
    assert_equal false, @normal_user.admin?
    assert_protected_get user_path(@normal_user), login_as: @admin
    assert_template 'users/show'
    assert_select "#user_notes", count: 1
  end

  test "non admins should not see profile notes" do
    assert_equal true,  @admin.admin?
    assert_equal false, @normal_user.admin?
    assert_protected_get profile_path(@normal_user), login_as: @normal_user
    assert_template 'users/show'
    assert_select "#user_notes", count: 0
  end

  test "admins should see links to share certificates" do
    assert_equal true,  @admin.admin?
    assert_equal false, @normal_user.admin?
    assert_protected_get user_path(@normal_user), login_as: @admin
    assert_template 'users/show'
    assert_select '.new_share_certificate_button', count: 1
    two_id = ActiveRecord::FixtureSet.identify(:two)
    assert_select "a[href='/share_certificates/#{two_id}/edit']", count: 1
    assert_select "a[href='/share_certificates/#{two_id}']", count: 1
  end

  test "non admins should not see links to share certificates" do
    assert_equal true,  @admin.admin?
    assert_equal false, @normal_user.admin?
    assert_protected_get profile_path(@normal_user), login_as: @normal_user
    assert_template 'users/show'
    assert_select '.new_share_certificate_button', count: 0
    two_id = ActiveRecord::FixtureSet.identify(:two)
    assert_select "a[href='/share_certificates/#{two_id}/edit']", count: 0
    assert_select "a[href='/share_certificates/#{two_id}']", count: 0
  end

end
