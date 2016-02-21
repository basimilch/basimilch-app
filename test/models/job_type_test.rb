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
    assert @job_type.valid?, "Initial fixture job_type should be valid: " +
                         @job_type.errors.full_messages.join(", ")
  end

  # TODO: Refactor a 'should be present' type of test

  test "title should be present" do
    assert @job_type.required_attribute?(:title)
    @job_type.title = nil
    assert_not @job_type.valid?
    @job_type.title = "    "
    assert_not @job_type.valid?
  end

  test "title should not be too long" do
    max_length = 150
    @job_type.title = "a" * max_length
    assert @job_type.valid?
    @job_type.title = "a" * (max_length + 1)
    assert_not @job_type.valid?
  end

  test "description should be present" do
    assert @job_type.required_attribute?(:description)
    @job_type.description = nil
    assert_not @job_type.valid?
    @job_type.description = "    "
    assert_not @job_type.valid?
  end

  test "description should not be too long" do
    max_length = 500
    @job_type.description = "a" * max_length
    assert @job_type.valid?
    @job_type.description = "a" * (max_length + 1)
    assert_not @job_type.valid?
  end

  test "place should be present" do
    assert @job_type.required_attribute?(:place)
    @job_type.place = nil
    assert_not @job_type.valid?
    @job_type.place = "    "
    assert_not @job_type.valid?
  end

  test "place should not be too long" do
    max_length = 150
    @job_type.place = "a" * max_length
    assert @job_type.valid?
    @job_type.place = "a" * (max_length + 1)
    assert_not @job_type.valid?
  end

  test "address should be present" do
    assert @job_type.required_attribute?(:address)
    @job_type.address = nil
    assert_not @job_type.valid?
    @job_type.address = "    "
    assert_not @job_type.valid?
  end

  test "address should not be too long" do
    max_length = 150
    @job_type.address = "a" * max_length
    assert @job_type.valid?
    @job_type.address = "a" * (max_length + 1)
    assert_not @job_type.valid?
  end

  test "slots should be present" do
    assert @job_type.required_attribute?(:slots)
    @job_type.slots = nil
    assert_not @job_type.valid?
  end

  test "slots should be a valid number" do
    @job_type.slots = "some string"
    assert_not @job_type.valid?
    @job_type.slots = -1
    assert_not @job_type.valid?
    @job_type.slots = 0
    assert_not @job_type.valid?
    @job_type.slots = 10000
    assert_not @job_type.valid?
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first - 1
    assert_not @job_type.valid?
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first
    assert @job_type.valid?
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last
    assert @job_type.valid?
    @job_type.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last + 1
    assert_not @job_type.valid?
  end

  test "user_id should be present" do
    assert @job_type.required_attribute?(:user_id)
    @job_type.user_id = nil
    assert_not @job_type.valid?
    @job_type.user_id = 0
    assert_not @job_type.valid?
  end
end
