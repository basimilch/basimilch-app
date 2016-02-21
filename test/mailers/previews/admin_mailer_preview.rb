# Preview all emails at http://localhost:3000/rails/mailers/admin_mailer
class AdminMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/admin_mailer/daily_activity_report
  def daily_activity_report
    AdminMailer.daily_activity_report
  end
end
