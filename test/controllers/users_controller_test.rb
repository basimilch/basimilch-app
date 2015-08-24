require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user       = users(:one)
    @other_user = users(:two)
  end

  test "should get index when logged in" do
    assert_protected_get :index, login_as: @user
    assert_response :success
    assert_select "title", "Alle Genossenschafter | my.basimilch"
  end

  test "should get new when logged in" do
    assert_protected_get :new, login_as: @user
    assert_response :success
    assert_select "title", "Neuer Genossenschafter | my.basimilch"
  end

  test "should redirect edit when not logged in" do
    assert_protected login_as: @user do
      get :edit, id: @user
    end
  end

  test "should redirect update when not logged in" do
    assert_protected login_as: @user do
      patch :update, id: @user, user: { name: @user.first_name,
                                        email: @user.email }
    end
  end

  test "should redirect edit when logged in as wrong user" do
    fixture_log_in(@other_user)
    assert_protected login_as: @user,
                     unlogged_redirect: { path:       root_url,
                                          template:   'users/index',
                                          with_flash: false} do
      get :edit, id: @user
    end
  end

  test "should redirect update when logged in as wrong user" do
    fixture_log_in(@other_user)
    assert_protected login_as: @user,
                     unlogged_redirect: { path:       root_url,
                                          template:   'users/index',
                                          with_flash: false} do

      patch :update, id: @user, user: { name: @user.first_name,
                                        email: @user.email }
    end
  end

  test "should allow the admin attribute to be edited by non admins" do
    fixture_log_in(@user)
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
end
