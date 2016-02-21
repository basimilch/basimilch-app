class JobType < ActiveRecord::Base

  belongs_to :user
  has_many :jobs

  validates :title,         presence: true, length: { maximum: 150 }
  validates :description,   presence: true, length: { maximum: 500 }
  validates :place,         presence: true, length: { maximum: 150 }
  validates :address,       presence: true, length: { maximum: 150 }
  validates :slots,         presence: true, numericality: {
                  greater_than_or_equal_to: Job::ALLOWED_NUMBER_OF_SLOTS.first,
                  less_than_or_equal_to:    Job::ALLOWED_NUMBER_OF_SLOTS.last
                }
  validates :user_id,       presence: true
  validate  :user_exists,   unless: Proc.new {|j| j.user_id.blank?}


  def to_s
    ("Job Type #{id}: #{title} - #{description}").truncate(100)
  end

  private
    # TODO: Extract a common helper with Job#user_exists
    def user_exists
      unless User.find_by(id: user_id)
        errors.add :user_id, I18n.t("errors.messages.user_not_found",
                                    id: user_id)
      end
    end
end
