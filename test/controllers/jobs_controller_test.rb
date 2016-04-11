require 'test_helper'

class JobsControllerTest < ActionController::TestCase

  setup do
    @admin_user = users(:one)
    @user       = users(:two)
    @job        = jobs(:one)
    @full_job   = jobs(:full_job)
    @full_job.job_signups.create(user: @user, author: @admin_user)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @user.admin?
    assert_equal false, @job.canceled?
    assert_equal false, @full_job.canceled?
    assert_equal true, @full_job.full?
    assert_equal @admin_user, @full_job.job_signups.first.author
    assert_equal false, @full_job.job_signups.first.self_signup?
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


  test "admin should be able to create past job" do
    assert_difference 'Job.count', 1 do
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
                                      user_id: @job.user_id,
                                      notes: "updated notes" }
    end
    assert_equal "updated notes", @job.reload.notes
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

  test "admin should not destroy not canceled job" do
    assert_equal false, @job.canceled?
    assert_no_difference 'Job.count' do
      assert_admin_protected login_as: @admin_user do
        delete :destroy, id: @job
      end
    end
    assert_redirected_to @job
  end

  test "admin should destroy canceled job" do
    assert_equal false, @job.canceled?
    assert_equal true,  @job.cancel(author: @user)
    assert_equal true,  @job.canceled?
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

  test "non admin user should be able to self sign up for future job" do
    assert_difference 'JobSignup.count', 1 do
      assert_protected login_as: @user do
        post :signup_current_user, id: jobs(:future_job).id
      end
    end
  end

  test "non admin user should not be able to self sign up for past job" do
    assert_no_difference 'JobSignup.count' do
      assert_protected login_as: @user do
        post :signup_current_user, id: jobs(:past_job).id
      end
    end
  end

  test "admin user should be able to sign up other users for future job" do
    assert_difference 'JobSignup.count', 2 do
      assert_admin_protected login_as: @admin_user do
        post :signup_users, id: jobs(:future_job).id,
                            users: [ @user.id, @admin_user.id ]

      end
    end
  end

  test "admin user should be able to sign up other users for past job" do
    assert_difference 'JobSignup.count', 2 do
      assert_admin_protected login_as: @admin_user do
        post :signup_users, id: jobs(:past_job).id,
                            users: [ @user.id, @admin_user.id ]

      end
    end
  end

  test "non admin user should not be able to sign up others for future job" do
    assert_no_difference 'JobSignup.count' do
      assert_admin_protected login_as: @user do
        post :signup_users, id: jobs(:future_job).id,
                            users: [ @user.id, @admin_user.id ]

      end
    end
  end

  test "admin user should not be able to self sign up for full job" do
    assert_equal true, @full_job.full?
    assert_no_difference 'JobSignup.count' do
      assert_protected login_as: @admin_user do
        post :signup_current_user, id: @full_job.id
      end
    end
  end

  test "non admin user should not be able to self sign up for full job" do
    assert_equal true, @full_job.full?
    assert_no_difference 'JobSignup.count' do
      assert_protected login_as: @user do
        post :signup_current_user, id: @full_job.id
      end
    end
  end

  test "admin user should not be able to sign up others for full job" do
    assert_equal true, @full_job.full?
    assert_no_difference 'JobSignup.count' do
      assert_admin_protected login_as: @admin_user do
        post :signup_users, id: @full_job.id,
                            users: [ @user.id, @admin_user.id ]
      end
    end
  end

  test "non admin user should not be able to sign up others for full job" do
    assert_equal true, @full_job.full?
    assert_no_difference 'JobSignup.count' do
      assert_admin_protected login_as: @user do
        post :signup_users, id: @full_job.id,
                            users: [ @user.id, @admin_user.id ]
      end
    end
  end

  test "admin user should be able to unregister a user form a job" do
    assert_equal @user, @full_job.users.first
    assert_difference 'JobSignup.not_canceled.count', -1 do
      assert_admin_protected login_as: @admin_user do
        put :cancel_job_signup,
            id: @full_job.id,
            job_signup_id: JobSignup.find_by(user: @user, job: @full_job).id
      end
    end
  end

  test "non-admin user should not be able to unregister a user form a job" do
    assert_equal @user, @full_job.users.first
    assert_no_difference 'JobSignup.not_canceled.count' do
      assert_admin_protected login_as: @user do
        put :cancel_job_signup,
            id: @full_job.id,
            job_signup_id: JobSignup.find_by(user: @user, job: @full_job).id
      end
    end
  end
end
