require 'test_helper'

class AdminMailerTest < ActionMailer::TestCase

  test "daily_activity_report" do
    mail = AdminMailer.daily_activity_report
    assert_equal "Daily activity report", mail.subject
    assert_equal ["daily_activity_report@example.org"], mail.to
    assert_equal ["noreply@example.org"], mail.from
    assert_match "There was no activity recorded yesterday", mail.body.encoded
  end
end
