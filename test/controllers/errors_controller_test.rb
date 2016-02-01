require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase

  test "should get 500 if unknown or nil code" do
    get :show
    assert_select ".error_page_image"
    assert_response :error
  end

  test "should get 500" do
    get :show, code: 500
    assert_select ".error_page_image"
    assert_response :error
  end

  test "should get 404" do
    get :show, code: 404
    assert_select ".error_page_image"
    assert_response :not_found
  end
end
