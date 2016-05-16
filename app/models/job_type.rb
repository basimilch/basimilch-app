class JobType < ActiveRecord::Base

  include Cancelable

  belongs_to :user
  has_many :jobs

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  default_scope -> { order(title: :asc).order(id: :asc) }

  validates :title,         presence: true, length: { maximum: 150 }
  validates :description,   presence: true, length: { maximum: 500 }
  validates :place,         presence: true, length: { maximum: 150 }
  validates :address,       presence: true, length: { maximum: 150 }
  validates :slots,         presence: true,
                              inclusion: { in: Job::ALLOWED_NUMBER_OF_SLOTS }
  validates :user_id,       presence: true
  validate_id_for :user


  def to_s
    ("Job Type #{id.inspect}: #{title.inspect} -" +
      " #{description.inspect}").truncate(100)
  end
end
