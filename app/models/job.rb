class Job < ActiveRecord::Base

  belongs_to :user
  has_many :job_signups

  default_scope -> { order(start_at: :asc) }
  scope :future, -> { where("start_at > ?", Time.current) }
  scope :in_current_year, -> { where("start_at > ?",
                                     Time.current.beginning_of_year) }

  validates :title,         presence: true
  validates :description,   presence: true
  validates :place,         presence: true
  validates :address,       presence: true
  validates :slots,         presence: true, numericality: { greater_than: 0 }
  validates :user_id,       presence: true
  validate  :user_exists,   unless: Proc.new {|j| j.user_id.blank?}
  validate  :correct_future_dates

  # Returns the job that will happen next.
  def self.next
    future.first
  end

  # Returns the list of jobs that will happen next.
  def self.following(n = 5)
    future.limit([n, 1].max)
  end

  def to_s
    ("Job #{id}: #{start_at.to_date.to_s :db}, #{start_at.to_s :time}-" +
     "#{start_at.to_s :time} - #{title}").truncate(100)
  end

  def signup_status
    count = job_signups.count
    return :success if count >= slots
    return :danger  if count < (0.4 * slots)
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

  def available?
    (not full?) && future?
  end

  def user_signed_up?(user)
    job_signups.each do |job_signup|
      return true if job_signup.user_id == user.id
    end
    return false
  end

  private

    def user_exists
      unless User.find_by(id: user_id)
        errors.add :user_id, I18n.t("errors.messages.user_not_found",
                                    id: user_id)
      end
    end

    def correct_future_dates
      if past?
        errors.add :start_at, I18n.t("errors.messages.job_must_be_future")
      elsif start_at >= end_at
        errors.add :start_at,
                   I18n.t("errors.messages.job_end_must_be_after_start")
      end
    end
end
