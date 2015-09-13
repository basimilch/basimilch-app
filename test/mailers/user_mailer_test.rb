require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  include SignupsHelper

  test "account_activation" do
    user = users(:two)
    user.activation_token = User.new_token
    user.activation_sent_at = Time.current
    mail = UserMailer.account_activation(user)
    assert_equal "Kontoaktivierung", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@basimil.ch"],  mail.from
    assert_match user.first_name,         mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "password_reset" do
    user = users(:three)
    user.password_reset_token = User.new_token
    user.password_reset_sent_at = Time.current
    mail = UserMailer.password_reset(user)
    assert_equal "Passwort Zurücksetzung",  mail.subject
    assert_equal [user.email],              mail.to
    assert_equal ["noreply@basimil.ch"],    mail.from
    assert_match user.password_reset_token, mail.body.encoded
    assert_match CGI::escape(user.email),   mail.body.encoded
  end

  test "email_validation" do
    user = users(:three)
    email_validation_code = rand_validation_code
    mail = UserMailer.email_validation(user, email_validation_code)
    assert_equal "Validierung der E-Mail-Adresse",  mail.subject
    assert_equal [user.email],                      mail.to
    assert_equal ["noreply@basimil.ch"],            mail.from
    assert_match email_validation_code,             mail.body.encoded
  end

  test "signup_successful" do
    user = users(:three)
    mail = UserMailer.signup_successful(user)
    assert_equal "Anmeldung erfolgreich",  mail.subject
    assert_equal [user.email],             mail.to
    assert_equal ["noreply@basimil.ch"],   mail.from
  end
end
