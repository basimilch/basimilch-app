class Job < ActiveRecord::Base

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common

  FREQUENCIES = [:just_once,
                 :repeat_weekly_4_times]

  ALLOWED_NUMBER_OF_SLOTS = (1..10)

  MIN_JOB_DURATION = 30.minutes
  MAX_JOB_DURATION = 8.hours

  # DOC: https://github.com/airblade/paper_trail/tree/v4.0.1#basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :user
  belongs_to :job_type
  has_many :job_signups
  has_many :users, -> {distinct}, through: :job_signups

  default_scope   -> { order(start_at: :asc) }
  scope :future,  -> { where("start_at > ?", Time.current) }
  scope :job_type, ->(id){ id == :all ? all : where(job_type_id: id) }
  scope :at_day,  ->(d){  where("start_at > ?", d.to_date.at_beginning_of_day)
                         .where("start_at < ?", d.to_date.at_end_of_day) }
  scope :today,     -> { at_day(Date.today) }
  scope :tomorrow,  -> { at_day(Date.tomorrow) }
  scope :in_current_year, -> { where("start_at > ?",
                                     Time.current.beginning_of_year) }

  validates :title,           presence: true, length: { maximum: 150 }
  validates :description,     presence: true, length: { maximum: 500 }
  validates :place,           presence: true, length: { maximum: 150 }
  validates :address,         presence: true, length: { maximum: 150 }
  validates :slots,           presence: true, numericality: {
                  greater_than_or_equal_to: ALLOWED_NUMBER_OF_SLOTS.first,
                  less_than_or_equal_to:    ALLOWED_NUMBER_OF_SLOTS.last
                }
  validates :user_id,         presence: true
  validate  :user_exists,     unless: Proc.new {|j| j.user_id.blank?}
  validate  :job_type_exists, unless: Proc.new {|j| j.job_type_id.blank?}
  validates :start_at,        presence: true
  validates :end_at,          presence: true
  validate  :correct_start_and_end_dates

  attr_accessor :creation_frequency


  def save_series
    # TODO: Improve the repeated creation of jobs.
    successfully_saved = save
    if successfully_saved && creation_frequency == "repeat_weekly_4_times"
      3.times do |i|
        job_copy = dup
        job_copy.start_at           = start_at + i.inc.weeks
        job_copy.end_at             = end_at   + i.inc.weeks
        job_copy.creation_frequency = nil
        job_copy.save
      end
    end
    successfully_saved
  end

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

  def full_date
    "#{start_at.to_date.to_localized_s :long_with_weekday}, " +
    "#{start_at.to_s :time} - #{end_at.to_s :time}"
  end

  def full_address
    "#{place} - #{address}"
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

  def send_reminders
    logger.info "Sending reminders for #{self}"
    users.each do |user|
      logger.info " - to #{user}"
      user.send_job_reminder self
    end
  end

  private

    def user_exists
      unless User.find_by(id: user_id)
        errors.add :user_id, I18n.t("errors.messages.user_not_found",
                                    id: user_id)
      end
    end

    def job_type_exists
      unless JobType.find_by(id: job_type_id)
        errors.add :job_type_id, I18n.t("errors.messages.job_type_not_found",
                                    id: job_type_id)
      end
    end

    def correct_start_and_end_dates
      return unless start_at && end_at
      if end_at <= start_at
        errors.add :end_at,
                   I18n.t("errors.messages.job_end_must_be_after_start")
      elsif end_at - start_at < MIN_JOB_DURATION ||
            end_at - start_at > MAX_JOB_DURATION
        errors.add :end_at,
                   I18n.t("errors.messages.job_end_must_be_between" +
                          "_30min_and__after_start")
      end
    end
end
