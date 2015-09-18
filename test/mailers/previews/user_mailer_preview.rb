# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  include SignupsHelper

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    user.activation_sent_at = Time.current
    UserMailer.account_activation(user)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.password_reset_token = User.new_token
    user.password_reset_sent_at = Time.current
    UserMailer.password_reset(user)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/email_validation
  def email_validation
    user = User.first
    email_validation_code = rand_validation_code
    UserMailer.email_validation(user, email_validation_code)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/finish_signup_later
  def finish_signup_later
    user = User.first
    UserMailer.finish_signup_later(user)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/signup_successful
  def signup_successful
    user = User.first
    UserMailer.signup_successful(user)
  end
end
