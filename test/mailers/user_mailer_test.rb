require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

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
    assert_equal "Passwort Zurücksetzung", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@basimil.ch"],  mail.from
    assert_match user.password_reset_token,        mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end
end
