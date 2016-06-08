class JobSignup < ActiveRecord::Base

  include Cancelable

  after_cancel    :notify_cancelation

  MIN_NUMBER_PER_USER_PER_YEAR = 4

  default_scope   -> { by_created_at }

  # DOC: http://www.informit.com/articles/article.aspx?p=2220311
  scope :in_current_year, -> { joins(:job).merge(Job.in_current_year) }
  scope :past,            -> { joins(:job).merge(Job.past) }
  scope :future,          -> { joins(:job).merge(Job.future) }
  scope :by_created_at,   -> { order(created_at: :asc) }
  scope :by_job_start_at, -> { remove_order.joins(:job).merge(Job.by_start_at) }

  belongs_to :user
  belongs_to :job

  # If the class name of the reference cannot be inferred from the relation name
  # the class name must be specified.
  # SOURCE: http://stackoverflow.com/a/29577869
  # DOC: http://api.rubyonrails.org/v4.2.6/classes/ActiveRecord/Associations
  #                                       /ClassMethods.html#method-i-belongs_to
  belongs_to :author, class_name: "User"

  validates :user_id, presence: true
  validate_id_for :user
  validates :job_id,  presence: true
  validate_id_for :job
  validate  :job_is_available,  unless: Proc.new {|j| j.job.nil?}
  validates :author_id, presence: true, numericality: { greater_than: 0 }
  validate  :author_is_entitled, unless: Proc.new {|j| j.author.nil?}

  def to_s
    "JobSignup #{id.inspect}: User #{user_id.inspect} " +
      "for Job #{job_id.inspect} " +
      ( self_signup? ? "(self signup)" : "(author: #{author_id.inspect})")
  end

  # Returns true if the user self signed up for the job, and false if another
  # user (an admin) did it on their behalf.
  def self_signup?
    user_id == author_id
  end

  private

    def job_is_available
      unless job.available? allow_past: author.try(:admin?)
        errors.add :base, I18n.t("errors.messages.job_does_not_accept_signups")
      end
    end

    def author_is_entitled
      unless author_id == user_id || author.admin?
        errors.add :base, I18n.t(
          "errors.messages.job_signup_author_not_entitled"
          )
      end
    end

    class CancellationReason < Enum
      enum :JOB_CANCELED
      enum :JOB_SIGNUP_CANCELED
    end

    def notify_cancelation
      case canceled_reason_key
      when CancellationReason::JOB_CANCELED
        UserMailer.job_canceled_notification(user, job).deliver_later
      when CancellationReason::JOB_SIGNUP_CANCELED
        UserMailer.job_signup_canceled_notification(user, job).deliver_later
      else
        logger.warn "Unexpected canceled_reason_key:" +
                    " #{canceled_reason_key.inspect} - Nothing to do."
      end
    end
end
