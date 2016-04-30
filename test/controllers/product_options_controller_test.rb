require 'test_helper'

class ProductOptionsControllerTest < ActionController::TestCase
  setup do
    @product_option = product_options(:one)

    @valid_product_option = {
      name: @product_option.name,
      description: @product_option.description,
      size: @product_option.size,
      size_unit: @product_option.size_unit,
      equivalent_in_milk_liters: @product_option.equivalent_in_milk_liters,
      notes: @product_option.notes
    }

    @admin_user = users(:one)
    @other_user = users(:two)

    assert_equal true,  @admin_user.admin?
    assert_equal false, @other_user.admin?

  end

  # get :index

  test "non-logged-in users should not get index" do
    get :index
    assert_redirected_to login_path
  end

  test "non-admin users should not get index" do
    assert_404_error do
      assert_protected_get :index, login_as: @other_user
    end
  end

  test "admin users should get index" do
    assert_protected_get :index, login_as: @admin_user
    assert_response :success
  end

  # get :new

  test "non-logged-in users should not get new" do
    get :new
    assert_redirected_to login_path
  end

  test "non-admin users should not get new" do
    assert_404_error do
      assert_protected_get :new, login_as: @other_user
    end
  end

  test "admin users should get new" do
    assert_protected_get :new, login_as: @admin_user
    assert_response :success
  end

  # get :show

  test "non-logged-in users should not get show" do
    get :show, id: @product_option
    assert_redirected_to login_path
  end

  test "non-admin users should not get show" do
    assert_404_error do
      assert_protected login_as: @other_user do
        get :show, id: @product_option
      end
    end
  end

  test "admin users should get show" do
    assert_protected login_as: @admin_user do
      get :show, id: @product_option
    end
    assert_response :success
  end

  # get :edit

  test "non-logged-in users should not get edit" do
    get :edit, id: @product_option
    assert_redirected_to login_path
  end

  test "non-admin users should not get edit" do
    assert_404_error do
      assert_protected login_as: @other_user do
        get :edit, id: @product_option
      end
    end
  end

  test "admin users should get edit" do
    assert_protected login_as: @admin_user do
      get :edit, id: @product_option
    end
    assert_response :success
  end

  # post :create

  test "non-logged-in should not create product_option" do
    assert_no_difference 'ProductOption.count' do
      post :create, product_option: @valid_product_option
    end
    assert_redirected_to login_path
  end

  test "non-admin should not create product_option" do
    assert_no_difference 'ProductOption.count' do
      assert_admin_protected login_as: @other_user do
        post :create, product_option: @valid_product_option
      end
    end
  end

  test "admin should create product_option" do
    assert_difference 'ProductOption.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, product_option: @valid_product_option
      end
    end
    assert_redirected_to product_option_path(assigns(:product_option))
  end


end
