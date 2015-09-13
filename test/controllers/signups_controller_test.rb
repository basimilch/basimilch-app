require 'test_helper'

class SignupsControllerTest < ActionController::TestCase

  test "should get signup page when no logged in" do
    get :new
    assert_response :success
    assert_select "title", "Anmelden | my.basimilch"
  end

  test "should get redirected to profile page when logged in" do
    fixture_log_in users(:one)
    get :new
    assert_response :redirect
  end

  test "user created with signup should be not activated" do
    valid_user_info = {
      first_name:     "User",
      last_name:      "Example",
      postal_address: "Alte Kindhauserstrasse 3",
      postal_code:    "8953",
      city:           "Dietikon",
      tel_mobile:     "076 111 11 11",
      email:          "user@example.com"
    }
    assert_equal nil, User.find_by(email: valid_user_info[:email])
    validation_code = "123-123"
    session[:signup_info] = valid_user_info
    session[:signup_validation_code] = validation_code.number
    post :create, signup: {
      email_validation_code: validation_code
    }
    assert_response :success
    assert User.find_by(email: valid_user_info[:email]), "User not created"
    assert_equal false, User.find_by(email: valid_user_info[:email]).activated?

    # Check that the session is cleaned from signup info
    assert_equal nil, session[:signup_info]
    assert_equal nil, session[:signup_validation_code]
  end
end
