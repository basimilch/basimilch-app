require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  def setup
    @valid_user_info_1 = {
      first_name:     "User",
      last_name:      "Example",
      postal_address: "Alte Kindhauserstrasse 3",
      postal_code:    "8953",
      city:           "Dietikon",
      tel_mobile:     "076 111 11 11",
      email:          "user@example.com",
      notes:          "some_notes"
    }
  end

  test "signup workflow" do
    signup_workflow_for_user @valid_user_info_1

    # Check that the signup can be performed twice on the same computer,
    # i.e. that another user (with a different email) can still signup.
    valid_user_info_2 = @valid_user_info_1.merge({
                email: "user2@example.com"
              })
    signup_workflow_for_user valid_user_info_2

    signup_with_existent_email_should_fail
  end

  private
    def signup_workflow_for_user(valid_user_info)
      # Landing to the singup page
      get signup_path
      assert_template 'signups/new'
      assert_equal nil, session[:already_successful_signup]

      incomplete_user_info = valid_user_info.merge({
                      first_name:     "user",
                      last_name:      "von example",
                      postal_address: "Alte Kindhauserstr 3"
                    })
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        # User tries a first attemp with partially correct information
        # and no email is sent yet
        post_via_redirect signup_validation_path, user: incomplete_user_info
      end

      # The same form is rendered with the information highlighted
      assert_template 'signups/new'
      # ...and/or fixed
      assert_select '[id=user_first_name][value=User]'
      assert_select '[id=user_last_name][value="Von Example"]'
      assert_select '[id=user_postal_address][value="Alte Kindhauserstrasse 3"]'
      assert_select '[id=user_notes]', text: "some_notes"
      # ...and the corresponding error messages to explain what happened
      assert_select 'div#error_explanation li',   count: 1

      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        # The user sends the form again with the information fixed
        # and one email is sent with the validation code
        post_via_redirect signup_validation_path, user: valid_user_info
      end
      # ...and the validation screen appears
      assert_template 'signups/validation'
      # The validation code is securely stored in the session cookie
      signup_validation_code = session[:signup_validation_code]
      assert_equal 6, signup_validation_code.length

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        # Entering a wrong validation code, renders the page again
        # and no welcome email is sent yet
        put_via_redirect signup_create_path,
                         signup: {
                          email_validation_code: "a"
                        }
      end
      assert_template 'signups/validation'

      assert_difference 'ActionMailer::Base.deliveries.size', 2 do
        # A successful user sign up should send 2 emails: a confirmation to the
        # user and a notification to the app owner.
        assert_difference 'User.count', 1 do
          # With the valid code, the user gets created
          # and a welcome email is sent
          put_via_redirect signup_create_path,
                           signup: {
                            email_validation_code: signup_validation_code
                          }
        end
      end
      assert_template 'signups/create'

      assert_no_difference ['User.count', 'ActionMailer::Base.deliveries.size'] do
        # Reloading the page (sending the request again) should not recreate
        # the user and no email should be sent again.
        put_via_redirect signup_create_path,
                         signup: {
                          email_validation_code: signup_validation_code
                        }
      end
      assert_template 'signups/create'

      # Check that the session is cleaned from signup info
      assert_equal nil, session[:signup_info]
      assert_equal nil, session[:signup_validation_code]
    end

    # This is not a standalone test to ensure that its executed after user did
    # signup.
    def signup_with_existent_email_should_fail
      # Landing to the singup page
      get signup_path
      assert_template 'signups/new'
      assert_equal nil, session[:already_successful_signup]

      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post_via_redirect signup_validation_path, user: @valid_user_info_1
      end

      # The same form is rendered with the information highlighted
      assert_template 'signups/new'
      # ...and the corresponding error messages to explain what happened
      assert_select 'div#error_explanation li',   count: 1
    end
end
