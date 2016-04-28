require 'test_helper'

class DepotsControllerTest < ActionController::TestCase

  setup do
    @depot = depots(:valid)

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
    get :show, id: @depot
    assert_redirected_to login_path
  end

  test "non-admin users should not get show" do
    assert_404_error do
      assert_protected login_as: @other_user do
        get :show, id: @depot
      end
    end
  end

  test "admin users should get show" do
    assert_protected login_as: @admin_user do
      get :show, id: @depot
    end
    assert_response :success
  end

  # get :edit

  test "non-logged-in users should not get edit" do
    get :edit, id: @depot
    assert_redirected_to login_path
  end

  test "non-admin users should not get edit" do
    assert_404_error do
      assert_protected login_as: @other_user do
        get :edit, id: @depot
      end
    end
  end

  test "admin users should get edit" do
    assert_protected login_as: @admin_user do
      get :edit, id: @depot
    end
    assert_response :success
  end

  # post :create

  test "non-logged-in should not create depot" do
    assert_no_difference 'Depot.count' do
      post :create, depot: {
        city: @depot.city,
        country: @depot.country,
        directions: @depot.directions,
        exact_map_coordinates: @depot.exact_map_coordinates,
        name: @depot.name,
        notes: @depot.notes,
        opening_hours: @depot.opening_hours,
        picture: @depot.picture,
        postal_address: @depot.postal_address,
        postal_address_supplement: @depot.postal_address_supplement,
        postal_code: @depot.postal_code
      }
    end
    assert_redirected_to login_path
  end

  test "non-admin should not create depot" do
    assert_no_difference 'Depot.count' do
      assert_admin_protected login_as: @other_user do
        post :create, depot: {
          city: @depot.city,
          country: @depot.country,
          directions: @depot.directions,
          exact_map_coordinates: @depot.exact_map_coordinates,
          name: @depot.name,
          notes: @depot.notes,
          opening_hours: @depot.opening_hours,
          picture: @depot.picture,
          postal_address: @depot.postal_address,
          postal_address_supplement: @depot.postal_address_supplement,
          postal_code: @depot.postal_code
        }
      end
    end
  end

  test "admin should create depot" do
    assert_difference 'Depot.count', 1 do
      assert_admin_protected login_as: @admin_user do
        post :create, depot: {
          city: @depot.city,
          country: @depot.country,
          directions: @depot.directions,
          exact_map_coordinates: @depot.exact_map_coordinates,
          name: @depot.name,
          notes: @depot.notes,
          opening_hours: @depot.opening_hours,
          picture: @depot.picture,
          postal_address: @depot.postal_address,
          postal_address_supplement: @depot.postal_address_supplement,
          postal_code: @depot.postal_code
        }
      end
    end
    assert_redirected_to depot_path(assigns(:depot))
  end

  # put :update, id: @depot

  test "non-logged-in should not update depot" do
    put :update, id: @depot, depot: {
      city: @depot.city,
      country: @depot.country,
      directions: @depot.directions,
      exact_map_coordinates: @depot.exact_map_coordinates,
      name: @depot.name,
      notes: @depot.notes,
      opening_hours: @depot.opening_hours,
      picture: @depot.picture,
      postal_address: @depot.postal_address,
      postal_address_supplement: @depot.postal_address_supplement,
      postal_code: @depot.postal_code
    }
    assert_redirected_to login_path
  end

  test "non-admin should not update depot" do
    assert_admin_protected login_as: @other_user do
      put :update, id: @depot, depot: {
        city: @depot.city,
        country: @depot.country,
        directions: @depot.directions,
        exact_map_coordinates: @depot.exact_map_coordinates,
        name: @depot.name,
        notes: @depot.notes,
        opening_hours: @depot.opening_hours,
        picture: @depot.picture,
        postal_address: @depot.postal_address,
        postal_address_supplement: @depot.postal_address_supplement,
        postal_code: @depot.postal_code
      }
    end
  end

  test "admin should update depot" do
    assert_admin_protected login_as: @admin_user do
      put :update, id: @depot, depot: {
        city: @depot.city,
        country: @depot.country,
        directions: @depot.directions,
        exact_map_coordinates: @depot.exact_map_coordinates,
        name: @depot.name,
        notes: @depot.notes,
        opening_hours: @depot.opening_hours,
        picture: @depot.picture,
        postal_address: @depot.postal_address,
        postal_address_supplement: @depot.postal_address_supplement,
        postal_code: @depot.postal_code
      }
    end
    assert_redirected_to depot_path(assigns(:depot))
  end

  # Add coordinator to depot

  test "admin should be able to add a coordinator" do
    assert_admin_protected login_as: @admin_user do
      put :update, id: @depot, depot: {
        coordinator_user_ids: [ users(:one).id ]
      }
    end
    assert_redirected_to depot_path(assigns(:depot))
    assert_equal users(:one), @depot.reload.coordinators.first.user
  end

  test "admin should be able to add a coordinator without mobile phone" do
    assert_equal true, users(:one).update_attribute(:tel_mobile, nil)
    assert_admin_protected login_as: @admin_user do
      put :update, id: @depot, depot: {
        coordinator_user_ids: [ users(:one).id ]
      }
    end
    assert_redirected_to depot_path(assigns(:depot))
    assert_equal users(:one), @depot.reload.coordinators.first.user
  end

  # Cancel depot

  test "admin should cancel depot" do
    assert @depot.coordinators.create(user: users(:one)).save
    fixture_log_in @admin_user
    assert_no_difference 'Depot.not_canceled.count' do
      # It should not be possible to cancel a depot with active coordinator(s)
      put :cancel, id: @depot
    end
    assert_equal 1, @depot.active_coordinators.count
    assert_no_difference '@depot.coordinators.count' do
      assert_difference '@depot.active_coordinators.count', -1 do
        put :cancel_coordinator,
              id: @depot,
              coordinator_id: @depot.coordinators.first.id
      end
    end
    assert_equal 0, @depot.active_coordinators.count
    assert_difference 'Depot.not_canceled.count', -1 do
      # It should be possible to cancel a depot with active coordinator(s)
      put :cancel, id: @depot
    end
    assert_redirected_to depot_path(assigns(:depot))
  end
end
