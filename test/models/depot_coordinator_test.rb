require 'test_helper'

class DepotCoordinatorTest < ActiveSupport::TestCase

  test "coordinators can be setup" do
    assert depots(:valid).coordinators.create(user: users(:admin)).save
    assert_equal users(:admin), depots(:valid).reload.coordinators.first.user
  end

  test "must be cancelable" do
    assert Cancelable.included_in?(DepotCoordinator)
  end
end
