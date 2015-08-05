require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_select "title", "All users | my.basimilch"
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_select "title", "New user | my.basimilch"
  end
end
