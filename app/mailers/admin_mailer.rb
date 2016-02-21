class AdminMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.admin_mailer.daily_activity_report.subject
  #
  # Used from the 'send_daily_activity_report_to_admin' rake task, scheduled
  # on heroku.
  def daily_activity_report
    @yesterday_activities = PublicActivity::Activity.of_yesterday.oldest_first
    m = mail to: ENV['EMAIL_DAILY_ACTIVITY_REPORT_ADDRESS']
    logger.info "Sending daily_activity_report to '#{m.to}' with" +
                " #{@yesterday_activities.count} activities."
  end
end
