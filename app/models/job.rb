class Job < ActiveRecord::Base

  belongs_to :user
  has_many :job_signups

  default_scope -> { order(start_at: :asc) }

  # Returns the job that will happen next.
  def self.next
    where("start_at > ?", Time.current).limit(1).first
  end

  # Returns the list of jobs that will happen next.
  def self.following(n = 5)
    where("start_at > ?", Time.current).limit([n, 1].max)
  end

  def to_s
    ("Job #{id}: #{start_at.to_date.to_s :db}, #{start_at.to_s :time}-" +
     "#{start_at.to_s :time} - #{title}").truncate(100)
  end

  def signup_status
    count = job_signups.count
    return :success if count >= slots
    return :danger  if count == 0
    :warning
  end

  def past?
    end_at < Time.current
  end

  def ongoing?
    start_at < Time.current && end_at > Time.current
  end

  def future?
    start_at > Time.current
  end

  def full?
    # TODO: Make a test to ensure that a job doesn't accept signups if it's full
    signup_status == :success
  end

  def user_signed_up?(user)
    job_signups.each do |job_signup|
      return true if job_signup.user_id == user.id
    end
    return false
  end
end
