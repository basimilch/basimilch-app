require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  def setup
    @valid_user_info_1 = valid_user_info_for_tests
  end

  test "signup workflow" do
    signup_workflow_for_user @valid_user_info_1

    # Check that the signup can be performed twice on the same computer,
    # i.e. that another user (with a different email) can still signup.
    valid_user_info_2 = @valid_user_info_1.merge({
                email: "user2@example.com"
              })
    signup_workflow_for_user valid_user_info_2
    assert_nil User.find_by(email: "user2@example.com").status

    # Check that if the user wants a subscription, the status is set to
    # "waiting_list".
    valid_user_info_3 = @valid_user_info_1.merge({
                email: "user3@example.com",
                wanted_subscription: "waiting_list_for_subscription"
              })
    signup_workflow_for_user valid_user_info_3
    user3 = User.find_by(email: "user3@example.com")
    assert_equal "waiting_list",              user3.status
    assert_equal User::Status::WAITING_LIST,  user3.status
    # ...and the status is stored as a string (not as an Enum object).
    assert_equal String, user3.status.class

    signup_with_existent_email_should_fail
  end

  private
    def signup_workflow_for_user(valid_user_info)
      # Landing to the singup page
      get signup_path
      assert_template 'signups/new'
      assert_nil session[:already_successful_signup]

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        # User tries a first attemp with partially correct information
        # and no email is sent yet
        post signup_validation_path, params: {
                                       user: valid_user_info.merge({
                                         first_name:     "user",
                                         last_name:      "von example",
                                         postal_address: "Alte Kindhauserstr 3"
                                       })
                                     }
        follow_redirect! while redirect?
      end

      # The same form is rendered with the information highlighted
      assert_template 'signups/new'
      # ...and/or fixed
      assert_select '[id=user_first_name][value=User]'
      assert_select '[id=user_last_name][value="Von Example"]'
      assert_select '[id=user_postal_address][value="Alte Kindhauserstrasse 3"]'
      assert_select '[id=user_postal_address_supplement][value="Hof Im Basi"]'
      assert_select '[id=user_postal_code][value="8953"]'
      assert_select '[id=user_city][value="Dietikon"]'
      assert_select '[id=user_tel_mobile][value="076 111 11 11"]'
      assert_select '[id=user_notes]', text: "some_notes"
      # ...and the corresponding error messages to explain what happened
      assert_select 'div#error_explanation li',   count: 1

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        # User has to check the box about accepting the terms and conditions.
        post signup_validation_path, params: {
               user: valid_user_info.merge({terms_of_service: "0"})
             }
        follow_redirect! while redirect?
      end

      # The same form is rendered with the information highlighted
      assert_template 'signups/new'
      # ...and/or fixed
      assert_select '[id=user_first_name][value=User]'
      assert_select '[id=user_last_name][value="Example"]'
      assert_select '[id=user_postal_address][value="Alte Kindhauserstrasse 3"]'
      assert_select '[id=user_postal_address_supplement][value="Hof Im Basi"]'
      assert_select '[id=user_postal_code][value="8953"]'
      assert_select '[id=user_city][value="Dietikon"]'
      assert_select '[id=user_tel_mobile][value="076 111 11 11"]'
      assert_select '[id=user_notes]', text: "some_notes"
      assert_select '.checkbox > .field_with_errors',   count: 1
      # ...and the corresponding error messages to explain what happened
      assert_select 'div#error_explanation li',   count: 1

      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        # The user sends the form again with the information fixed
        # and one email is sent with the validation code
        post signup_validation_path, params: { user: valid_user_info }
        follow_redirect! while redirect?
      end
      # ...and the validation screen appears
      assert_template 'signups/validation'
      # The validation code is securely stored in the session cookie
      signup_validation_code = session[:signup_validation_code]
      assert_equal 6, signup_validation_code.length

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        # Entering a wrong validation code, renders the page again
        # and no welcome email is sent yet
        assert_no_difference 'User.count' do
          put signup_create_path, params: {
                                    signup: { email_validation_code: "a" }
                                  }
          follow_redirect! while redirect?
        end
      end
      assert_template 'signups/validation'

      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        # A successful user sign up should send 2 emails: a confirmation to the
        # user and a notification to the app owner.
        assert_difference 'User.count', 1 do
          # With the valid code, the user gets created
          # and a welcome email is sent
          put signup_create_path, params: {
                                    signup: {
                                     email_validation_code: signup_validation_code
                                   }
                                 }
          follow_redirect! while redirect?
        end
      end
      assert_template 'signups/create'

      assert_no_difference ['User.count', 'ActionMailer::Base.deliveries.size'] do
        # Reloading the page (sending the request again) should not recreate
        # the user and no email should be sent again.
        put signup_create_path, params: {
                                  signup: {
                                   email_validation_code: signup_validation_code
                                  }
                                }
        follow_redirect! while redirect?
      end
      assert_template 'signups/create'

      # Check that the session is cleaned from signup info
      assert_nil session[:signup_info]
      assert_nil session[:signup_validation_code]
    end

    # This is not a standalone test to ensure that its executed after user did
    # signup.
    def signup_with_existent_email_should_fail
      # Landing to the singup page
      get signup_path
      assert_template 'signups/new'
      assert_nil session[:already_successful_signup]

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post signup_validation_path, params: { user: @valid_user_info_1 }
        follow_redirect! while redirect?
      end

      # The same form is rendered with the information highlighted
      assert_template 'signups/new'
      # ...and the corresponding error messages to explain what happened
      assert_select 'div#error_explanation li',   count: 1
    end
end
