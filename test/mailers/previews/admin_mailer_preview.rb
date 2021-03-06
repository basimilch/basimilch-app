# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/daily_activity_report
  def daily_activity_report
    AdminMailer.daily_activity_report
  end

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/activity_warning_notification
  def activity_warning_notification
    AdminMailer.activity_warning_notification(PublicActivity::Activity.first)
  end
end
