require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @valid_user_info = {
      first_name:     "User",
      last_name:      "Example",
      postal_address: "Alte Kindhauserstrasse 3",
      postal_code:    "8953",
      city:           "Dietikon",
      tel_mobile:     "076 111 11 11",
      email:          "user@example.com"
    }
    @incomplete_user_info = @valid_user_info.merge({
                        first_name:     "user",
                        last_name:      "example",
                        postal_address: "Alte Kindhauserstr 3"
                      })
    end

  test "signup workflow" do
    # Landing to the singup page
    get signup_path
    assert_template 'signups/new'

    # User tries a first attemp with partially correct information
    post_via_redirect signup_validation_path, user: @incomplete_user_info

    # The same form is rendered with the information highlighted
    assert_template 'signups/new'
    # ...and/or fixed
    assert_select '[id=user_first_name][value=User]'
    assert_select '[id=user_last_name][value=Example]'
    assert_select '[id=user_postal_address][value="Alte Kindhauserstrasse 3"]'
    # ...and the corresponding error messages to explain what happened
    assert_select 'div#error_explanation li',   count: 1
    # ...and not email is sent yet
    assert_equal 0, ActionMailer::Base.deliveries.size

    # The user sends the form again with the information fixed
    post_via_redirect signup_validation_path, user: @valid_user_info
    # ...and the validation screen appears
    assert_template 'signups/validation'
    # ...and one email is sent with the validation code
    assert_equal 1, ActionMailer::Base.deliveries.size
    # ...which is securely stored in the session cookie
    signup_validation_code = session[:signup_validation_code]
    assert_equal 6, signup_validation_code.length

    # Entering a wrong validation code, renders the page again
    put_via_redirect signup_create_path,
                     signup: {
                      email_validation_code: "a"
                    }
    assert_template 'signups/validation'
    assert_equal 1, ActionMailer::Base.deliveries.size

    # With the valid code, the user gets created
    assert_difference 'User.count', 1 do
      put_via_redirect signup_create_path,
                       signup: {
                        email_validation_code: signup_validation_code
                      }
      assert_template 'signups/create'
      assert_equal 2, ActionMailer::Base.deliveries.size
    end

    # Check that the session is cleaned from signup info
    assert_equal nil, session[:signup_info]
    assert_equal nil, session[:signup_validation_code]
  end
end
