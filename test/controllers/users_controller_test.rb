require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @admin_user = users(:one)
    @other_user = users(:two)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @other_user.admin?
  end

  test "should get index when logged in" do
    assert_protected_get :index, login_as: @admin_user
    assert_response :success
    assert_select "title", "Alle Genossenschafter_innen | meine.basimil.ch"
  end

  test "should get new when logged in" do
    assert_protected_get :new, login_as: @admin_user
    assert_response :success
    assert_select "title", "Neue_r Genossenschafter_in | meine.basimil.ch"
  end

  test "should redirect edit when not logged in" do
    assert_protected login_as: @admin_user do
      get :edit, id: @admin_user
    end
  end

  test "should redirect update when not logged in" do
    assert_protected login_as: @admin_user do
      patch :update, id: @admin_user, user: { name: @admin_user.first_name,
                                        email: @admin_user.email }
    end
  end

  test "should redirect edit when logged in as wrong user" do
    fixture_log_in(@other_user)
    assert_protected login_as: @admin_user,
                     unlogged_redirect: { path:       root_url,
                                          template:   'users/index',
                                          with_flash: false} do
      get :edit, id: @admin_user
    end
  end

  test "should redirect update when logged in as wrong user" do
    fixture_log_in(@other_user)
    assert_protected login_as: @admin_user,
                     unlogged_redirect: { path:       root_url,
                                          template:   'users/index',
                                          with_flash: false} do

      patch :update, id: @admin_user, user: { name: @admin_user.first_name,
                                        email: @admin_user.email }
    end
  end

  test "should allow the admin attribute to be edited by admins" do
    fixture_log_in(@admin_user)
    assert_not @other_user.admin?
    patch :update, id: @other_user, user: { admin: true }
    assert @other_user.reload.admin?
  end

  test "should not allow the admin attribute to be edited by non admins" do
    fixture_log_in(@other_user)
    assert_not @other_user.admin?
    patch :update, id: @other_user, user: { admin: true }
    assert_not @other_user.reload.admin?
  end

  test "admin should be able to edit profile notes" do
    fixture_log_in(@admin_user)
    assert_not_equal "some notes", @other_user.reload.notes
    patch :update, id: @other_user, user: { notes: "some notes" }
    assert_equal "some notes", @other_user.reload.notes
  end

  test "non-admin should not be able to edit profile notes" do
    fixture_log_in(@other_user)
    assert_not @other_user.admin?
    assert_not_equal "some notes", @other_user.reload.notes
    patch :update, id: @other_user, user: { notes: "some notes" }
    assert_not_equal "some notes", @other_user.reload.notes
  end

  test "admin should be able to edit user email" do
    fixture_log_in(@admin_user)
    assert_equal "two@example.com", @other_user.reload.email
    patch :update, id: @other_user, user: { email: "updated@email.com" }
    assert_equal "updated@email.com", @other_user.reload.email
  end

  test "non-admin should not be able to edit user email" do
    fixture_log_in(@other_user)
    assert_not @other_user.admin?
    assert_equal "two@example.com", @other_user.reload.email
    patch :update, id: @other_user, user: { email: "updated@email.com" }
    assert_equal "two@example.com", @other_user.reload.email
  end
end
