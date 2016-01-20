require 'test_helper'

class JobSignupTest < ActiveSupport::TestCase

  test "should be possible to signup for an available job" do
    job_signup = jobs(:future_job).job_signups.build(user_id: users(:one).id)
    assert job_signup.valid?
  end

  test "should not be possible to signup for an unavailable job" do
    job_signup = jobs(:past_job).job_signups.build(user_id: users(:one).id)
    assert_not job_signup.valid?
  end
end
