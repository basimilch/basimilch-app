require 'test_helper'

class JobWorkflowTest < ActionDispatch::IntegrationTest

  # NOTE: 'def setup' is equivalent to 'setup do' in Rails' Test::Unit context.
  # SOURCE: http://technicalpickles.com/posts/
  #                            rails-special-sauce-test-unit-setup-and-teardown/
  setup do
    @admin_user = users(:one)
    @user       = users(:two)
    @past_job   = jobs(:past_job)
    @future_job = jobs(:future_job)
    @full_job   = jobs(:full_job)
    @full_job.job_signups.create(user: @user, author: @admin_user)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @user.admin?

    assert_equal false, @past_job.full?
    assert_equal true,  @past_job.past?

    assert_equal false, @future_job.full?
    assert_equal false, @future_job.past?

    assert_equal true,   @full_job.full?
    assert_equal false,  @full_job.past?
    assert_equal @admin_user, @full_job.job_signups.first.author
    assert_equal false, @full_job.job_signups.first.self_signup?
  end

  test "deleting a job should delete dependent job_signups and send email" do
    get root_url
    fixture_log_in @admin_user
    assert_difference ['Job.count', 'JobSignup.count'], -1 do
      assert_difference 'ActionMailer::Base.deliveries.size', 1 do
        # Cancelling a job should send a notification to the signed up users.
        delete job_path(@full_job)
      end
    end
  end
end
