require 'test_helper'

class SignupsControllerTest < ActionController::TestCase

  def setup
    @valid_user_info = valid_user_info_for_tests
  end

  test "should get signup page when no logged in" do
    get :new
    assert_response :success
    assert_select "title", "Anmelden | meine.basimil.ch"
  end

  test "should get redirected to profile page when logged in" do
    fixture_log_in users(:admin)
    get :new
    assert_response :redirect
  end

  test "user created with signup should be not activated" do
    assert_nil User.find_by(email: @valid_user_info[:email])
    validation_code = "123-123"
    session[:signup_info] = @valid_user_info
    session[:signup_validation_code] = validation_code.number
    assert_difference 'PublicActivity::Activity.count', 6 do
      # A successful user sign up should create 6 activities: one for each email
      # sent and one with key :new_user_signup, plus one for each share
      # certificate created.
      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        # A successful user sign up should send 2 emails: a confirmation to the
        # user and a notification to the app owner.
        assert_difference 'ShareCertificate.count', 3 do
          # This successful user sign up should create 3 share certificates.
          post :create, signup: {
            email_validation_code: validation_code
          }
        end
      end
    end
    assert_response :success
    assert User.find_by(email: @valid_user_info[:email]), "User not created"
    assert_equal false, User.find_by(email: @valid_user_info[:email]).activated?

    # Check that the session is cleaned from signup info
    assert_nil session[:signup_info]
    assert_nil session[:signup_validation_code]
  end
end
