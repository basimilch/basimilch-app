require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  setup do
    @admin_user = users(:one)
    @user = users(:two)
    @job = jobs(:one)
  end

  test "user should get index" do
    assert_protected_get :index, login_as: @user
    assert_response :success
  end

  test "admin should get new" do
    assert_admin_protected_get :new, login_as: @admin_user
    assert_response :success
  end

  test "non admin should not get new" do
    assert_admin_protected_get :new, login_as: @user
    assert_response :success
  end

  test "admin should create job" do
    assert_difference 'Job.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, job: { address: @job.address,
                             description: @job.description,
                             place: @job.place,
                             slots: @job.slots,
                             start_at: 1.day.from_now,
                             end_at: 1.day.from_now + 1.hour,
                             title: @job.title,
                             user_id: @job.user_id }
      end
    end
    assert_redirected_to job_path(assigns(:job))
  end

  test "non admin should not create job" do
    assert_no_difference 'Job.count' do
      assert_admin_protected login_as: @user do
        post :create, job: { address: @job.address,
                             description: @job.description,
                             place: @job.place,
                             slots: @job.slots,
                             start_at: 1.day.from_now,
                             end_at: 1.day.from_now + 1.hour,
                             title: @job.title,
                             user_id: @job.user_id }
      end
    end
  end


  test "admin should not create past job" do
    assert_no_difference 'Job.count' do
      assert_admin_protected login_as: @admin_user do
        post :create, job: { address: @job.address,
                             description: @job.description,
                             place: @job.place,
                             slots: @job.slots,
                             start_at: 1.day.ago,
                             end_at: 1.day.ago + 1.hour,
                             title: @job.title,
                             user_id: @job.user_id }
      end
    end
  end


  test "user should show job" do
    assert_protected login_as: @user do
      get :show, id: @job
    end
    assert_response :success
  end

  test "admin should get edit" do
    assert_admin_protected login_as: @admin_user do
      get :edit, id: @job
    end
    assert_response :success
  end

  test "non admin should not get edit" do
    assert_admin_protected login_as: @user do
      get :edit, id: @job
    end
    assert_response :success
  end

  test "admin should update job" do
    assert_admin_protected login_as: @admin_user do
      patch :update, id: @job, job: { address: @job.address,
                                      description: @job.description,
                                      place: @job.place,
                                      slots: @job.slots,
                                      start_at: 1.day.from_now,
                                      end_at: 1.day.from_now + 1.hour,
                                      title: @job.title,
                                      user_id: @job.user_id }
    end
    assert_redirected_to job_path(assigns(:job))
  end

  test "non admin should not update job" do
    assert_admin_protected login_as: @user do
      patch :update, id: @job, job: { address: @job.address,
                                      description: @job.description,
                                      place: @job.place,
                                      slots: @job.slots,
                                      start_at: 1.day.from_now,
                                      end_at: 1.day.from_now + 1.hour,
                                      title: @job.title,
                                      user_id: @job.user_id }
    end
  end

  test "admin should destroy job" do
    assert_difference 'Job.count', -1 do
      assert_admin_protected login_as: @admin_user do
        delete :destroy, id: @job
      end
    end
    assert_redirected_to jobs_path
  end

  test "non admin should not destroy job" do
    assert_no_difference 'Job.count' do
      assert_admin_protected login_as: @user do
        delete :destroy, id: @job
      end
    end
  end
end
