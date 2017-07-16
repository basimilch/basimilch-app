require 'test_helper'

class JobSignupTest < ActiveSupport::TestCase

  def setup
    @admin_user = users(:admin)
    @other_user = users(:two)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @other_user.admin?

    @job_signup = jobs(:future_job).job_signups.build(user:   @other_user,
                                                      author: @admin_user)
    assert_equal true, @job_signup.valid?
  end

  test "should not be possible to create a signup without user_id" do
    job_signup = jobs(:future_job).job_signups.build
    assert_not_valid job_signup
  end

  test "should not be possible to create a signup without job_id" do
    job_signup = users(:admin).job_signups.build
    assert_not_valid job_signup
  end

  test "should not be possible to signup for a non existing job_id" do
    job_signup = users(:admin).job_signups.build(job_id: -1)
    assert_not_valid job_signup
  end

  test "should not be possible to signup for an available job without author" do
    job_signup = jobs(:future_job).job_signups.build(user: @other_user)
    assert_not_valid job_signup
  end

  test "should be possible to auto-signup for an available job" do
    job_signup = jobs(:future_job).job_signups.build(user:   @other_user,
                                                     author: @other_user)
    assert_valid job_signup
  end

  test "admin should be able to signup other user for an available job" do
    job_signup = jobs(:future_job).job_signups.build(user:   @other_user,
                                                     author: @admin_user)
    assert_valid job_signup
  end

  test "non-admin should not be able to signup other user for an available job" do
    job_signup = jobs(:future_job).job_signups.build(user:   @admin_user,
                                                     author: @other_user)
    assert_not_valid job_signup
  end

  test "should not be possible to signup for an unavailable job" do
    job_signup = jobs(:past_job).job_signups.build(user:   @other_user,
                                                   author: @other_user)
    assert_not_valid job_signup
  end

  test "job signup must be cancelable" do
    assert Cancelable.included_in?(JobSignup)
    assert_equal false, @job_signup.canceled?
    assert_nil   @job_signup.canceled_by
    assert_nil   @job_signup.canceled_reason
  end
end
