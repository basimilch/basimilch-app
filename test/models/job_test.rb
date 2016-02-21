require 'test_helper'

class JobTest < ActiveSupport::TestCase

  def setup
    @job = Job.new(title:        "some title",
                   description:  "some description",
                   place:        "some place",
                   address:      "some address",
                   start_at:     Time.current,
                   end_at:       Time.current + 3.hours,
                   slots:        3,
                   user_id:      User.first.id,
                   job_type_id:  JobType.first.id)
  end

  test "fixture job should be valid" do
    assert @job.valid?, "Initial fixture job should be valid: " +
                         @job.errors.full_messages.join(", ")
  end

  # TODO: Refactor a 'should be present' type of test

  test "title should be present" do
    assert @job.required_attribute?(:title)
    @job.title = nil
    assert_not @job.valid?
    @job.title = "    "
    assert_not @job.valid?
  end

  test "title should not be too long" do
    max_length = 150
    @job.title = "a" * max_length
    assert @job.valid?
    @job.title = "a" * (max_length + 1)
    assert_not @job.valid?
  end

  test "description should be present" do
    assert @job.required_attribute?(:description)
    @job.description = nil
    assert_not @job.valid?
    @job.description = "    "
    assert_not @job.valid?
  end

  test "description should not be too long" do
    max_length = 500
    @job.description = "a" * max_length
    assert @job.valid?
    @job.description = "a" * (max_length + 1)
    assert_not @job.valid?
  end

  test "place should be present" do
    assert @job.required_attribute?(:place)
    @job.place = nil
    assert_not @job.valid?
    @job.place = "    "
    assert_not @job.valid?
  end

  test "place should not be too long" do
    max_length = 150
    @job.place = "a" * max_length
    assert @job.valid?
    @job.place = "a" * (max_length + 1)
    assert_not @job.valid?
  end

  test "address should be present" do
    assert @job.required_attribute?(:address)
    @job.address = nil
    assert_not @job.valid?
    @job.address = "    "
    assert_not @job.valid?
  end

  test "address should not be too long" do
    max_length = 150
    @job.address = "a" * max_length
    assert @job.valid?
    @job.address = "a" * (max_length + 1)
    assert_not @job.valid?
  end

  test "slots should be present" do
    assert @job.required_attribute?(:slots)
    @job.slots = nil
    assert_not @job.valid?
  end

  test "slots should be a valid number" do
    @job.slots = "some string"
    assert_not @job.valid?
    @job.slots = -1
    assert_not @job.valid?
    @job.slots = 0
    assert_not @job.valid?
    @job.slots = 10000
    assert_not @job.valid?
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first - 1
    assert_not @job.valid?
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first
    assert @job.valid?
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last
    assert @job.valid?
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last + 1
    assert_not @job.valid?
  end

  test "user_id should be present" do
    assert @job.required_attribute?(:user_id)
    @job.user_id = nil
    assert_not @job.valid?
  end

  test "user_id must be of an existent user" do
    @job.user_id = -1
    assert_not @job.valid?
    @job.user_id = 0
    assert_not @job.valid?
    @job.user_id = User.last.id + 1
    assert_not @job.valid?
    @job.user_id = User.first.id
    assert @job.valid?
  end

  test "start_at should be present" do
    assert @job.required_attribute?(:start_at)
    @job.start_at = nil
    assert_not @job.valid?
  end

  test "end_at should be present" do
    assert @job.required_attribute?(:end_at)
    @job.end_at = nil
    assert_not @job.valid?
  end

  test "end_at should be between 30 minutes and 8 hours after start_at" do
    @job.end_at = @job.start_at - 1.minute
    assert_not @job.valid?
    @job.end_at = @job.start_at
    assert_not @job.valid?
    @job.end_at = @job.start_at + 29.minutes
    assert_not @job.valid?
    @job.end_at = @job.start_at + 30.minutes
    assert @job.valid?
    @job.end_at = @job.start_at + 8.hours
    assert @job.valid?
    @job.end_at = @job.start_at + 8.hours + 1.minute
    assert_not @job.valid?
  end

  test "job_type_id needs not to be present" do
    assert_not @job.required_attribute?(:job_type_id)
    @job.job_type_id = nil
    assert @job.valid?
  end

  test "job_type_id must be of an existent job_type if present" do
    @job.job_type_id = -1
    assert_not @job.valid?
    @job.job_type_id = JobType.last.id + 1
    assert_not @job.valid?
    @job.job_type_id = JobType.first.id
    assert @job.valid?
  end
end
