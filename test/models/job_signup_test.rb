require 'test_helper'

class JobSignupTest < ActiveSupport::TestCase

  test "should not be possible to create a signup without user_id" do
    job_signup = jobs(:future_job).job_signups.build
    assert_not_valid job_signup
  end

  test "should not be possible to create a signup without job_id" do
    job_signup = users(:one).job_signups.build
    assert_not_valid job_signup
  end

  test "should not be possible to signup for a non existing job_id" do
    job_signup = users(:one).job_signups.build(job_id: -1)
    assert_not_valid job_signup
  end

  test "should be possible to signup for an available job" do
    job_signup = jobs(:future_job).job_signups.build(user_id: users(:one).id)
    assert_valid job_signup
  end

  test "should not be possible to signup for an unavailable job" do
    job_signup = jobs(:past_job).job_signups.build(user_id: users(:one).id)
    assert_not_valid job_signup
  end
end
