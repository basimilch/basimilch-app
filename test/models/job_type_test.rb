require 'test_helper'

class JobTypeTest < ActiveSupport::TestCase

  def setup
    @job_type = JobType.new(title:        "some title",
                            description:  "some description",
                            place:        "some place",
                            address:      "some address",
                            slots:        3,
                            user_id:      1)
  end

  test "fixture job_type should be valid" do
    assert_valid @job_type, "Initial fixture job_type should be valid."
  end

  # TODO: Refactor a 'should be present' type of test

  test "title should be present" do
    assert_required_attribute @job_type, :title
    @job_type.title = nil
    assert_not_valid @job_type
    @job_type.title = "    "
    assert_not_valid @job_type
  end

  test "title should not be too long" do
    max_length = 150
    @job_type.title = "a" * max_length
    assert_valid @job_type
    @job_type.title = "a" * (max_length + 1)
    assert_not_valid @job_type
  end

  test "description should be present" do
    assert_required_attribute @job_type, :description
    @job_type.description = nil
    assert_not_valid @job_type
    @job_type.description = "    "
    assert_not_valid @job_type
  end

  test "description should not be too long" do
    max_length = 500
    @job_type.description = "a" * max_length
    assert_valid @job_type
    @job_type.description = "a" * (max_length + 1)
    assert_not_valid @job_type
  end

  test "place should be present" do
    assert_required_attribute @job_type, :place
    @job_type.place = nil
    assert_not_valid @job_type
    @job_type.place = "    "
    assert_not_valid @job_type
  end

  test "place should not be too long" do
    max_length = 150
    @job_type.place = "a" * max_length
    assert_valid @job_type
    @job_type.place = "a" * (max_length + 1)
    assert_not_valid @job_type
  end

  test "address should be present" do
    assert_required_attribute @job_type, :address
    @job_type.address = nil
    assert_not_valid @job_type
    @job_type.address = "    "
    assert_not_valid @job_type
  end

  test "address should not be too long" do
    max_length = 150
    @job_type.address = "a" * max_length
    assert_valid @job_type
    @job_type.address = "a" * (max_length + 1)
    assert_not_valid @job_type
  end

  test "slots should be present" do
    assert_required_attribute @job_type, :slots
    @job_type.slots = nil
    assert_not_valid @job_type
  end

  test "slots should be a valid number" do
    @job_type.slots = "some string"
    assert_not_valid @job_type
    @job_type.slots = -1
    assert_not_valid @job_type
    @job_type.slots = 0
    assert_not_valid @job_type
    @job_type.slots = 10000
    assert_not_valid @job_type
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first - 1
    assert_not_valid @job_type
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first
    assert_valid @job_type
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last
    assert_valid @job_type
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last + 1
    assert_not_valid @job_type
  end

  test "user_id should be present" do
    assert_required_attribute @job_type, :user_id
    @job_type.user_id = nil
    assert_not_valid @job_type
    @job_type.user_id = 0
    assert_not_valid @job_type
  end

  test "job_type must be cancelable" do
    assert Cancelable.included_in?(JobType)
    assert_equal false, @job_type.canceled?
    assert_equal nil,   @job_type.canceled_by
    assert_equal nil,   @job_type.canceled_reason
  end

  test "unsaved job_type cannot be canceled" do
    assert_equal false, @job_type.canceled?
    assert_raises ActiveRecord::RecordNotFound do
      @job_type.cancel
    end
    assert_equal false, @job_type.canceled?
  end

  test "saved job_type cannot be canceled without an author" do
    assert_equal false, @job_type.canceled?
    assert_equal true,  @job_type.save
    assert_raises RuntimeError do
      @job_type.cancel
    end
    assert_equal false, @job_type.canceled?
  end

  test "saved job_type can be canceled" do
    assert_equal false, @job_type.canceled?
    assert_equal true,  @job_type.save
    assert_equal true,  @job_type.cancel(author: users(:admin))
    assert_equal true,  @job_type.canceled?
  end

  test "saved job_type cannot be canceled twice" do
    assert_equal false, @job_type.canceled?
    assert_equal true,  @job_type.save
    assert_equal true,  @job_type.cancel(author: users(:admin))
    assert_equal true,  @job_type.canceled?
    assert_equal false, @job_type.cancel(author: users(:admin))
    assert_equal true,  @job_type.canceled?
  end

  test "canceled job_type must have an author" do
    assert_equal false,       @job_type.canceled?
    assert_equal true,        @job_type.save
    assert_equal true,        @job_type.cancel(author: users(:admin))
    assert_equal true,        @job_type.canceled?
    assert_equal users(:admin), @job_type.canceled_by
  end

  test "canceled job_type cannot be edited" do
    assert_equal false,         @job_type.canceled?
    assert_equal true,          @job_type.save
    @job_type.title = "new title 1"
    assert_equal true,          @job_type.save
    assert_equal "new title 1", @job_type.reload.title
    assert_equal true,          @job_type.cancel(author: users(:admin))
    assert_equal true,          @job_type.canceled?
    @job_type.title = "new title 2"
    assert_equal false,         @job_type.save
    assert_equal "new title 2", @job_type.title
    assert_equal "new title 1", @job_type.reload.title
  end
end
