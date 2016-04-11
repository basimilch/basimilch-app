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
    assert_valid @job, "Initial fixture job should be valid."
  end

  # TODO: Refactor a 'should be present' type of test

  test "title should be present" do
    assert @job.required_attribute?(:title)
    @job.title = nil
    assert_not_valid @job
    @job.title = "    "
    assert_not_valid @job
  end

  test "title should not be too long" do
    max_length = 150
    @job.title = "a" * max_length
    assert_valid @job
    @job.title = "a" * (max_length + 1)
    assert_not_valid @job
  end

  test "description should be present" do
    assert @job.required_attribute?(:description)
    @job.description = nil
    assert_not_valid @job
    @job.description = "    "
    assert_not_valid @job
  end

  test "description should not be too long" do
    max_length = 500
    @job.description = "a" * max_length
    assert_valid @job
    @job.description = "a" * (max_length + 1)
    assert_not_valid @job
  end

  test "place should be present" do
    assert @job.required_attribute?(:place)
    @job.place = nil
    assert_not_valid @job
    @job.place = "    "
    assert_not_valid @job
  end

  test "place should not be too long" do
    max_length = 150
    @job.place = "a" * max_length
    assert_valid @job
    @job.place = "a" * (max_length + 1)
    assert_not_valid @job
  end

  test "address should be present" do
    assert @job.required_attribute?(:address)
    @job.address = nil
    assert_not_valid @job
    @job.address = "    "
    assert_not_valid @job
  end

  test "address should not be too long" do
    max_length = 150
    @job.address = "a" * max_length
    assert_valid @job
    @job.address = "a" * (max_length + 1)
    assert_not_valid @job
  end

  test "slots should be present" do
    assert @job.required_attribute?(:slots)
    @job.slots = nil
    assert_not_valid @job
  end

  test "slots should be a valid number" do
    @job.slots = "some string"
    assert_not_valid @job
    @job.slots = -1
    assert_not_valid @job
    @job.slots = 0
    assert_not_valid @job
    @job.slots = 10000
    assert_not_valid @job
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first - 1
    assert_not_valid @job
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.first
    assert_valid @job
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last
    assert_valid @job
    @job.slots = Job::ALLOWED_NUMBER_OF_SLOTS.last + 1
    assert_not_valid @job
  end

  test "user_id should be present" do
    assert @job.required_attribute?(:user_id)
    @job.user_id = nil
    assert_not_valid @job
  end

  test "user_id must be of an existent user" do
    @job.user_id = -1
    assert_not_valid @job
    @job.user_id = 0
    assert_not_valid @job
    @job.user_id = User.last.id + 1
    assert_not_valid @job
    @job.user_id = User.first.id
    assert_valid @job
  end

  test "start_at should be present" do
    assert @job.required_attribute?(:start_at)
    @job.start_at = nil
    assert_not_valid @job
  end

  test "end_at should be present" do
    assert @job.required_attribute?(:end_at)
    @job.end_at = nil
    assert_not_valid @job
  end

  test "end_at should be between 30 minutes and 8 hours after start_at" do
    @job.end_at = @job.start_at - 1.minute
    assert_not_valid @job
    @job.end_at = @job.start_at
    assert_not_valid @job
    @job.end_at = @job.start_at + 29.minutes
    assert_not_valid @job
    @job.end_at = @job.start_at + 30.minutes
    assert_valid @job
    @job.end_at = @job.start_at + 8.hours
    assert_valid @job
    @job.end_at = @job.start_at + 8.hours + 1.minute
    assert_not_valid @job
  end

  test "job_type_id needs not to be present" do
    assert_not @job.required_attribute?(:job_type_id)
    @job.job_type_id = nil
    assert_valid @job
  end

  test "job_type_id must be of an existent job_type if present" do
    @job.job_type_id = -1
    assert_not_valid @job
    @job.job_type_id = JobType.last.id + 1
    assert_not_valid @job
    @job.job_type_id = JobType.first.id
    assert_valid @job
  end

  test "job must be cancelable" do
    assert Cancelable.included_in?(Job)
    assert_equal false, @job.canceled?
    assert_equal nil,   @job.canceled_by
    assert_equal nil,   @job.canceled_reason
  end

  test "unsaved job cannot be canceled" do
    assert_equal false, @job.canceled?
    assert_raises ActiveRecord::RecordNotFound do
      @job.cancel
    end
    assert_equal false, @job.canceled?
  end

  test "saved job cannot be canceled without an author" do
    assert_equal false, @job.canceled?
    assert_equal true,  @job.save
    assert_raises RuntimeError do
      @job.cancel
    end
    assert_equal false, @job.canceled?
  end

  test "saved job can be canceled" do
    assert_equal false, @job.canceled?
    assert_equal true,  @job.save
    assert_equal true,  @job.cancel(author: users(:one))
    assert_equal true,  @job.canceled?
  end

  test "saved job cannot be canceled twice" do
    assert_equal false, @job.canceled?
    assert_equal true,  @job.save
    assert_equal true,  @job.cancel(author: users(:one))
    assert_equal true,  @job.canceled?
    assert_equal false, @job.cancel(author: users(:one))
    assert_equal true,  @job.canceled?
  end

  test "canceled job must have an author" do
    assert_equal false,       @job.canceled?
    assert_equal true,        @job.save
    assert_equal true,        @job.cancel(author: users(:one))
    assert_equal true,        @job.canceled?
    assert_equal users(:one), @job.canceled_by
  end

  test "canceled job cannot be edited" do
    assert_equal false,         @job.canceled?
    assert_equal true,          @job.save
    @job.title = "new title 1"
    assert_equal true,          @job.save
    assert_equal "new title 1", @job.reload.title
    assert_equal true,          @job.cancel(author: users(:one))
    assert_equal true,          @job.canceled?
    @job.title = "new title 2"
    assert_equal false,         @job.save
    assert_equal "new title 2", @job.title
    assert_equal "new title 1", @job.reload.title
  end
end
