class UserMailer < ApplicationMailer

  include PublicActivityHelper

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

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.new_signup_notification.subject
  #
  def new_signup_notification(user, location_info)
    if not email = ENV['EMAIL_NEW_USER_NOTIFICATION_ADDRESS']
      logger.warn "ENV['EMAIL_NEW_USER_NOTIFICATION_ADDRESS'] is empty." +
                  " No new_signup_notification sent."
      return
    end
    logger.info "Sending notification about new user #{user.id} to '#{email}')"
    @user = user
    @location_info = location_info
    mail to: email,
         subject: t(".subject", id: user.id, full_name: user.full_name)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.job_reminder.subject
  #
  def job_reminder(user, job)
    @user = user
    @job = job
    mail to: "#{user.full_name} <#{user.email}>",
         subject: t(".subject", job_title: job.title)
    record_activity :send_job_reminder, @user, data: {job: @job}
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.job_canceled_notification.subject
  #
  def job_canceled_notification(user, job)
    # TODO: Consider sending only one email to all concerned users.
    @user = user
    @job = job
    @job_coordinator = job.user
    mail to: "#{user.full_name} <#{user.email}>",
         cc: "#{@job_coordinator.full_name} <#{@job_coordinator.email}>",
         subject: t(".subject", job_title: job.title,
                                job_date: @job.start_at.to_date.to_localized_s(:short_with_weekday))
    record_activity :send_job_canceled_notification, @user, data: {job: @job}
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   de-CH.user_mailer.job_signup_canceled_notification.subject
  #
  def job_signup_canceled_notification(user, job)
    # TODO: Consider sending only one email to all concerned users.
    @user = user
    @job = job
    @job_coordinator = job.user
    mail to: "#{user.full_name} <#{user.email}>",
         cc: "#{@job_coordinator.full_name} <#{@job_coordinator.email}>",
         subject: t(".subject", job_title: job.title,
                                job_date: @job.start_at.to_date.to_localized_s(:short_with_weekday))
    record_activity :send_job_signup_canceled_notification, @user, data: {job: @job}
  end
end
