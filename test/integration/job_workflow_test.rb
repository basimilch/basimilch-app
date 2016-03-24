require 'test_helper'

class JobWorkflowTest < ActionDispatch::IntegrationTest

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

  test "destroying a job should destroy dependent job_signups" do
    assert_difference 'Job.count', -1 do
      assert_difference 'JobSignup.count', -1 do
        @full_job.destroy
      end
    end
  end
end
