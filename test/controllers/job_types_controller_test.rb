require 'test_helper'

class JobTypesControllerTest < ActionController::TestCase
  setup do
    @admin_user = users(:one)
    @user = users(:two)
    @job_type = job_types(:one)
  end

  test "admin should get index" do
    assert_admin_protected_get :index, login_as: @admin_user
    assert_response :success
  end

  test "non admin should not get index" do
    assert_admin_protected_get :index, login_as: @user
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

  test "admin should create job_type" do
    assert_difference 'JobType.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, job_type: { address:      @job_type.address,
                                  description:  @job_type.description,
                                  place:        @job_type.place,
                                  slots:        @job_type.slots,
                                  title:        @job_type.title,
                                  user_id:      @job_type.user_id }
      end
    end
    assert_redirected_to job_type_path(assigns(:job_type))
  end

  test "non admin should not create job_type" do
    assert_no_difference 'JobType.count' do
      assert_admin_protected login_as: @user do
        post :create, job_type: { address:      @job_type.address,
                                  description:  @job_type.description,
                                  place:        @job_type.place,
                                  slots:        @job_type.slots,
                                  title:        @job_type.title,
                                  user_id:      @job_type.user_id }
      end
    end
  end

  test "admin should show job_type" do
    assert_admin_protected login_as: @admin_user do
      get :show, id: @job_type
    end
    assert_response :success
  end

  test "non admin should not show job_type" do
    assert_admin_protected login_as: @user do
      get :show, id: @job_type
    end
    assert_response :success
  end

  test "admin should get edit" do
    assert_admin_protected login_as: @admin_user do
      get :edit, id: @job_type
    end
    assert_response :success
  end

  test "admin should update job_type" do
    assert_admin_protected login_as: @admin_user do
      patch :update, id: @job_type, job_type: {address:     @job_type.address,
                                              description:  @job_type.description,
                                              place:        @job_type.place,
                                              slots:        @job_type.slots,
                                              title:        "some new title",
                                              user_id:      @job_type.user_id }
     end
     assert_equal "some new title", @job_type.reload.title
    assert_redirected_to job_type_path(assigns(:job_type))
  end

  test "non admin should not update job_type" do
    assert_admin_protected login_as: @user do
      patch :update, id: @job_type, job_type: {address:     @job_type.address,
                                              description:  @job_type.description,
                                              place:        @job_type.place,
                                              slots:        @job_type.slots,
                                              title:        "some new title",
                                              user_id:      @job_type.user_id }
    end
    assert_not_equal "some new title", @job_type.reload.title
  end

  test "admin should not destroy not canceled job_type" do
    assert_equal false, @job_type.canceled?
    assert_no_difference 'JobType.count' do
      assert_admin_protected login_as: @admin_user do
        delete :destroy, id: @job_type
      end
    end
    assert_redirected_to job_types_path
  end

  test "admin should destroy canceled job_type" do
    assert_equal false, @job_type.canceled?
    assert_equal true,  @job_type.cancel(author: @user)
    assert_equal true,  @job_type.canceled?
    assert_difference 'JobType.count', -1 do
      assert_admin_protected login_as: @admin_user do
        delete :destroy, id: @job_type
      end
    end
    assert_redirected_to job_types_path
  end

  test "non admin should destroy job_type" do
    assert_no_difference 'JobType.count' do
      assert_admin_protected login_as: @user do
        delete :destroy, id: @job_type
      end
    end
  end
end
