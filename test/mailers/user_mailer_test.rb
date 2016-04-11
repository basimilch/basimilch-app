require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  include ApplicationHelper

  test "account_activation" do
    user = users(:two)
    user.activation_sent_at = Time.current
    mail = UserMailer.account_activation(user)
    assert_equal "Kontoaktivierung",      mail.subject
    assert_equal [user.email],            mail.to
    assert_equal ["noreply@example.org"], mail.from
    assert_match user.first_name,         mail.body.encoded
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "email_validation" do
    user = users(:three)
    email_validation_code = rand_validation_code
    mail = UserMailer.email_validation(user, email_validation_code)
    assert_equal "Validierung der E-Mail-Adresse",  mail.subject
    assert_equal [user.email],                      mail.to
    assert_equal ["noreply@example.org"],           mail.from
    assert_match email_validation_code,             mail.body.encoded
  end

  test "login_code" do
    user = users(:three)
    login_code = rand_validation_code
    mail = UserMailer.login_code(user,
                                 login_code,
                                 SessionsController::LOGIN_CODE_VALIDITY)
    assert_equal "Login Code",                  mail.subject
    assert_equal [user.email],                  mail.to
    assert_equal ["noreply@example.org"],       mail.from
    assert_match login_code,                    mail.body.encoded
    assert_match "login/#{login_code.number}",  mail.body.encoded
  end

  test "signup_successful" do
    user = users(:three)
    mail = UserMailer.signup_successful(user)
    assert_equal "Anmeldung erfolgreich",  mail.subject
    assert_equal [user.email],             mail.to
    assert_equal ["noreply@example.org"],  mail.from
  end

  test "job_canceled_notification" do
    user = users(:three)
    job  = jobs(:one)
    mail = UserMailer.job_canceled_notification(user, job)
    assert_equal "Einsatz ABGESAGT: MyString am So, 17. Jan", mail.subject
    assert_equal [user.email],             mail.to
    assert_equal [users(:one).email],      mail.cc
    assert_equal ["noreply@example.org"],  mail.from
  end

  test "job_signup_canceled_notification" do
    user = users(:three)
    job  = jobs(:one)
    mail = UserMailer.job_signup_canceled_notification(user, job)
    assert_equal "Deine Anmeldung für MyString am So, 17. Jan wurde abgesagt",
                                           mail.subject
    assert_equal [user.email],             mail.to
    assert_equal [users(:one).email],      mail.cc
    assert_equal ["noreply@example.org"],  mail.from
  end

  test "new_self_job_signup_confirmation" do
    user = users(:three)
    job  = jobs(:one)
    mail = UserMailer.new_self_job_signup_confirmation(user, job)
    assert_equal "Anmeldebestätigung: MyString am So, 17. Jan",
                                           mail.subject
    assert_equal [user.email],             mail.to
    assert_equal ["noreply@example.org"],  mail.from
  end

  test "new_job_signup_by_admin_confirmation" do
    user          = users(:three)
    job           = jobs(:one)
    current_user  = users(:two)
    mail = UserMailer.new_job_signup_by_admin_confirmation(user,
                                                           job,
                                                           current_user)
    assert_equal "Anmeldebestätigung: MyString am So, 17. Jan",
                                           mail.subject
    assert_equal [user.email],             mail.to
    assert_equal [users(:two).email],      mail.cc
    assert_equal ["noreply@example.org"],  mail.from
  end
end
