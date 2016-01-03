class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.account_activation.subject
  #
  def account_activation(user)
    @user = user
    mail to: "#{user.full_name} <#{user.email}>"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: "#{user.full_name} <#{user.email}>"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.email_validation.subject
  #
  def email_validation(user, email_validation_code)
    @user = user
    @email_validation_code = email_validation_code
    mail to: "#{user.full_name} <#{user.email}>"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.login_code.subject
  #
  def login_code(user, login_code, login_code_validity)
    @user = user
    @login_code = login_code
    @login_code_validity = login_code_validity
    mail to: "#{user.full_name} <#{user.email}>"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.finish_signup_later.subject
  #
  def finish_signup_later(user)
    @user = user
    mail to: "#{user.full_name} <#{user.email}>"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.signup_successful.subject
  #
  def signup_successful(user)
    @user = user
    mail to: "#{user.full_name} <#{user.email}>"
  end
end
