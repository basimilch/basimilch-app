class Job < ActiveRecord::Base

  FREQUENCIES = [:just_once,
                 :repeat_weekly_4_times]

  ALLOWED_NUMBER_OF_SLOTS = (1..5)

  belongs_to :user
  has_many :job_signups
  has_many :users, -> {distinct}, through: :job_signups

  default_scope   -> { order(start_at: :asc) }
  scope :future,  -> { where("start_at > ?", Time.current) }
  scope :at_day,  ->(d){  where("start_at > ?", d.to_date.at_beginning_of_day)
                         .where("start_at < ?", d.to_date.at_end_of_day) }
  scope :today,     -> { at_day(Date.today) }
  scope :tomorrow,  -> { at_day(Date.tomorrow) }
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

  attr_accessor :creation_frequency


  def save
    # TODO: Improve the repeated creation of jobs.
    successfully_saved = super
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

    def correct_future_dates
      if past?
        errors.add :start_at, I18n.t("errors.messages.job_must_be_future")
      elsif start_at >= end_at
        errors.add :start_at,
                   I18n.t("errors.messages.job_end_must_be_after_start")
      end
    end
end
