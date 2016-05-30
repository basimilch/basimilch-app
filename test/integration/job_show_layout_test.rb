require 'test_helper'

class JobShowLayoutTest < ActionDispatch::IntegrationTest

  setup do
    @admin_user = users(:admin)
    @user       = users(:two)
    @past_job   = jobs(:past_job)
    @future_job = jobs(:future_job)
    @full_job   = jobs(:full_job)
    @full_job.job_signups.create(user: @user, author: @admin_user)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @user.admin?

    assert_equal false, @past_job.full?
    assert_equal true,  @past_job.past?
    assert_equal 3,     @past_job.current_job_signups.count

    assert_equal false, @future_job.full?
    assert_equal false, @future_job.past?

    assert_equal true,   @full_job.full?
    assert_equal false,  @full_job.past?
    assert_equal @admin_user, @full_job.job_signups.first.author
    assert_equal false, @full_job.job_signups.first.self_signup?
  end

  test "job page layout for an available job logged in as admin user" do
    assert_layout job: @future_job, logged_in_as: @admin_user,
                  self_signup_button_shown:       true,
                  signup_others_button_shown:     true,
                  notes_shown:                    true
  end

  test "job page layout for an available job logged in as non-admin user" do
    assert_layout job: @future_job, logged_in_as: @user,
                  self_signup_button_shown:       true
  end

  test "job page layout for a past job logged in as admin user" do
    assert_layout job: @past_job, logged_in_as: @admin_user,
                  unregister_others_button_shown: true,
                  signup_others_button_shown:     true,
                  notes_shown:                    true,
                  past_job_alert_shown:           true
  end

  test "job page layout for a past job logged in as non-admin user" do
    assert_layout job: @past_job, logged_in_as: @user,
                  past_job_alert_shown:           true
  end

  test "job page layout for a full job logged in as admin user" do
    assert_layout job: @full_job, logged_in_as: @admin_user,
                  unregister_others_button_shown: true,
                  notes_shown:                    true,
                  full_job_alert_shown:           true
  end

  test "job page layout for a full job logged in as non-admin user" do
    assert_layout job: @full_job, logged_in_as: @user,
                  full_job_alert_shown:           true
  end

  private

    def assert_layout(job:                            nil,
                      logged_in_as:                   nil,
                      self_signup_button_shown:       false,
                      signup_others_button_shown:     false,
                      unregister_others_button_shown: false,
                      notes_shown:                    false,
                      full_job_alert_shown:           false,
                      past_job_alert_shown:           false)
      assert_protected_get job_path(job), login_as: logged_in_as
      assert_template 'jobs/show'
      assert_select  "form[action='/jobs/#{job.id}/signup']",
                      count: (self_signup_button_shown ? 1 : 0)
      assert_select  "form[action='/jobs/#{job.id}/signup_users']",
                      count: (signup_others_button_shown ? 1 : 0)
      assert_select  "[href='/jobs/#{job.id}/cancel_job_signup/#{
                        JobSignup.find_by(user: @user, job: job).try(:id)
                      }']",
                      {count: (unregister_others_button_shown ? 1 : 0)}
      assert_select  "textarea[name='job[notes]']",
                      count: (notes_shown ? 1 : 0)
      assert_select  ".alert-success",
                      count: (full_job_alert_shown ? 1 : 0)
      assert_select  ".alert-warning",
                      count: (past_job_alert_shown ? 1 : 0)

    end
end
