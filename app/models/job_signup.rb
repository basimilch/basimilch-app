class JobSignup < ActiveRecord::Base

  MIN_NUMBER_PER_USER_PER_YEAR = 4

  # DOC: http://www.informit.com/articles/article.aspx?p=2220311
  scope :in_current_year, -> { joins(:job).merge(Job.in_current_year) }

  belongs_to :user
  belongs_to :job

  validate :job_is_available

  private

    def job_is_available
      unless job.available?
        errors.add :base, I18n.t("errors.messages.job_does_not_accept_signups")
      end
    end
end
