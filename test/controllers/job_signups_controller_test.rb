require 'test_helper'

class JobSignupsControllerTest < ActionController::TestCase
  setup do
    @job_signup = job_signups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_signups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_signup" do
    assert_difference('JobSignup.count') do
      post :create, job_signup: { job_id: @job_signup.job_id, user_id: @job_signup.user_id }
    end

    assert_redirected_to job_signup_path(assigns(:job_signup))
  end

  test "should show job_signup" do
    get :show, id: @job_signup
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job_signup
    assert_response :success
  end

  test "should update job_signup" do
    patch :update, id: @job_signup, job_signup: { job_id: @job_signup.job_id, user_id: @job_signup.user_id }
    assert_redirected_to job_signup_path(assigns(:job_signup))
  end

  test "should destroy job_signup" do
    assert_difference('JobSignup.count', -1) do
      delete :destroy, id: @job_signup
    end

    assert_redirected_to job_signups_path
  end
end
