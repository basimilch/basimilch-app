require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
  end

  test "unsuccessful edit" do
    ensure_protected_get edit_user_path(@user), @user
    assert_template 'users/edit'
    patch user_path(@user), user: { email: "wrong email" }
    # The errors are rendered
    assert_select '#error_explanation', count: 1
    # ...and we edit page is shown again.
    assert_template 'users/edit'
  end

  test "successful edit" do
    ensure_protected_get edit_user_path(@user), @user
    assert_template 'users/edit'
    email = "new_user@example.net"
    last_name = User.new_token # A random string
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
end
