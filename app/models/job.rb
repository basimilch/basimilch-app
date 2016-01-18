class Job < ActiveRecord::Base
  belongs_to :user
  has_many :job_signups

  default_scope -> { order(start_at: :asc) }

  def singup_status
    count = job_signups.count
    return :success if count >= slots
    return :danger  if count == 0
    :warning
  end
end
