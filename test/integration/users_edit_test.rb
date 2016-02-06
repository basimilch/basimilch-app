require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @other_user = users(:two)
  end

  test "unsuccessful edit" do
    assert_protected_get edit_user_path(@user), login_as: @user
    assert_template 'users/edit'
    patch user_path(@user), user: { email: "wrong email" }
    # The errors are rendered
    assert_select '#error_explanation', count: 1
    # ...and we edit page is shown again.
    assert_template 'users/edit'
  end

  test "successful edit" do
    assert_protected_get edit_user_path(@user), login_as: @user
    assert_template 'users/edit'
    email = "new_user@example.net"
    last_name = User.new_token.titlecase # A random string
    original_first_name = @user.first_name
    patch user_path(@user), user: { email:      email,
                                    last_name:  last_name }
    # We want a confirmation message.
    assert_not flash.empty?
    assert_redirected_to @users
    @user.reload
    assert_equal email,               @user.email
    assert_equal last_name,           @user.last_name
    # The things that are not provided remain unchanged.
    assert_equal original_first_name, @user.first_name
  end

  test "edit with friendly forwarding" do
    get edit_user_path(@user)
    fixture_log_in @user
    assert_redirected_to edit_user_path(@user)
  end

  test "admins should see 'Admin' input in user edit form" do
    assert_equal true,  @user.admin?
    assert_equal false, @other_user.admin?
    assert_protected_get edit_user_path(@other_user), login_as: @user
    assert_template 'users/edit'
    assert_select '#user_admin'
  end

  test "non admin users should not see 'Admin' input in user edit form" do
    assert_equal false, @other_user.admin?
    assert_protected_get edit_user_path(@other_user), login_as: @other_user
    assert_template 'users/edit'
    assert_select '#user_admin', count: 0
  end

  test "admins should see profile notes" do
    assert_equal true,  @user.admin?
    assert_equal false, @other_user.admin?
    assert_protected_get edit_user_path(@other_user), login_as: @user
    assert_template 'users/edit'
    assert_select "#user_notes", count: 1
  end

  test "non admins should not see profile notes" do
    assert_equal true,  @user.admin?
    assert_equal false, @other_user.admin?
    assert_protected_get profile_edit_path(@other_user), login_as: @other_user
    assert_template 'users/edit'
    assert_select "#user_notes", count: 0
  end

end
