require 'test_helper'

class ErrorPagesTest < ActionDispatch::IntegrationTest

  test "should get custom 500 page" do
    get "/500", code: 500
    assert_select ".error_page_image"
    assert_response :error
  end

  test "should get custom 404 page if unknown route" do
    # NOTE: In order to get the test render the error page instead of raising
    #       an exception, see: /config/environments/test.rb#19-23
    get "/non-existent-path"
    assert_select ".error_page_image"
    assert_response :not_found
  end

  test "should get custom 404 page" do
    get "/404", code: 404
    assert_select ".error_page_image"
    assert_response :not_found
  end

end
