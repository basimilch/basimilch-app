# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  include ApplicationHelper

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_sent_at = Time.current
    UserMailer.account_activation(user)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/email_validation
  def email_validation
    user = User.first
    email_validation_code = rand_validation_code
    UserMailer.email_validation(user, email_validation_code)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/login_code
  def login_code
    user = User.first
    login_code_code = rand_validation_code
    UserMailer.login_code(user, login_code_code,
                          SessionsController::LOGIN_CODE_VALIDITY)
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

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/new_signup_notification
  def new_signup_notification
    user = User.first
    UserMailer.new_signup_notification(user, "x.x.x.x (aprox y)")
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/job_reminder
  def job_reminder
    UserMailer.job_reminder(User.first, Job.first)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/job_canceled_notification
  def job_canceled_notification
    UserMailer.job_canceled_notification(User.first, Job.first)
  end

  # Preview this email at
  #   http://localhost:3000/rails/mailers/user_mailer/job_signup_canceled_notification
  def job_signup_canceled_notification
    UserMailer.job_signup_canceled_notification(User.first, Job.first)
  end
end
