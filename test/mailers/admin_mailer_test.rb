require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase

  test "daily_activity_report" do
    mail = AdminMailer.daily_activity_report
    assert_equal "Daily activity report", mail.subject
    assert_equal ["daily_activity_report@example.org"], mail.to
    assert_equal ["noreply@example.org"], mail.from
    assert_match "No activity recorded", mail.body.encoded
  end

  test "activity_warning_notification" do
    activity = PublicActivity::Activity.new
    mail = AdminMailer.activity_warning_notification(activity)
    assert_equal "Activity warning notification", mail.subject
    assert_equal ["daily_activity_report@example.org"], mail.to
    assert_equal ["noreply@example.org"], mail.from
    assert_match "AdminMailer#activity_warning_notification", mail.body.encoded
  end
end
