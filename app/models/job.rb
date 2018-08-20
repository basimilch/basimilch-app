class Job < ApplicationRecord

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common

  include Cancelable

  before_cancel   :cancel_signups

  FREQUENCIES = [:just_once,
                 :repeat_weekly_4_times]

  ALLOWED_NUMBER_OF_SLOTS = (1..10)

  MIN_JOB_DURATION = 30.minutes
  MAX_JOB_DURATION = 8.hours

  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#1c-basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :user
  # TODO: Check if it makes sense to remove 'optional: true' below
  belongs_to :job_type, optional: true
  # DOC: http://guides.rubyonrails.org/v5.2.1/association_basics.html#dependent
  has_many :job_signups, dependent: :destroy
  has_many :users,
           -> { distinct.merge(JobSignup.not_canceled).remove_order },
           through: :job_signups

  default_scope         -> { by_start_at }
  scope :by_start_at,   -> { order(start_at: :asc) }
  scope :future,        -> { where("start_at > ?", Time.current) }
  scope :past,          -> { where("start_at < ?", Time.current) }
  scope :job_type,      ->(id) { id == :all ? all : where(job_type_id: id) }
  scope :within_period, ->(t1, t2) {  where("start_at > ?", t1)
                                     .where("start_at < ?", t2) }
  scope :at_day,  ->(d) { within_period(d.to_date.at_beginning_of_day,
                                        d.to_date.at_end_of_day) }
  scope :today,     -> { at_day(Date.current) }
  scope :tomorrow,  -> { at_day(Date.tomorrow) }
  scope :in_current_year, -> { within_period(Time.current.beginning_of_year,
                                             Time.current.end_of_year) }
  scope :in_this_years_month, ->(m) do
    month = m.to_i
    # SOURCE: http://stackoverflow.com/a/10001043
    return none unless (1..12).include? month
    # SOURCE: http://stackoverflow.com/a/15652429
    month_date = DateTime.new(Time.current.year, month)
    bom = month_date.beginning_of_month
    eom = month_date.end_of_month
    where("start_at >= ? and start_at <= ?", bom, eom)
  end

  validates :title,           presence: true, length: { maximum: 150 }
  validates :description,     presence: true, length: { maximum: 500 }
  validates :place,           presence: true, length: { maximum: 150 }
  validates :address,         presence: true, length: { maximum: 150 }
  validates :slots,           presence: true,
                              inclusion: { in: ALLOWED_NUMBER_OF_SLOTS }
  validates :user_id,         presence: true
  validate_id_for :user
  validate_id_for :job_type
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
    ("Job #{id.inspect}: #{start_at.try(:to_date).try(:to_s, :db).inspect}," +
     " #{start_at.try(:to_s, :time).inspect}-" +
     "#{start_at.try(:to_s, :time).inspect} - #{title.inspect}" +
     "#{canceled? ? " (canceled)" : ""}").truncate(100)
  end

  def full_date
    "#{start_at.to_date.to_localized_s :long}, " +
    "#{start_at.to_s :time} - #{end_at.to_s :time}"
  end

  def full_address
    "#{place} - #{address}"
  end

  # Returns the job signups of this job that has not been canceled.
  def current_job_signups
    job_signups.not_canceled
  end

  def signup_status
    count = current_job_signups.count
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
    signup_status == :success
  end

  def available?(allow_past: false)
    (not full?) && (allow_past || future?)
  end

  def user_signed_up?(user)
    current_job_signups.each do |job_signup|
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

    def correct_start_and_end_dates
      return unless start_at && end_at
      if end_at <= start_at
        errors.add :end_at,
                   I18n.t("errors.messages.job_end_must_be_after_start")
      elsif end_at - start_at < MIN_JOB_DURATION ||
            end_at - start_at > MAX_JOB_DURATION
        errors.add :end_at,
                   I18n.t("errors.messages.job_end_must_be_between" +
                          "_30min_and_after_start")
      end
    end

    def cancel_signups
      job_signups.each do |job_signup|
        job_signup.cancel reason:   canceled_reason,
                        reason_key: JobSignup::CancellationReason::JOB_CANCELED,
                        author:     canceled_by_id
      end
    end
end
