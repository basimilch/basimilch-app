require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
  end

  test "should get index when logged in" do
    ensure_protected_get :index, @user
    assert_response :success
    assert_select "title", "Alle Benutzer | my.basimilch"
  end

  test "should get new when logged in" do
    ensure_protected_get :new, @user
    assert_response :success
    assert_select "title", "Neuer Benutzer | my.basimilch"
  end
end
