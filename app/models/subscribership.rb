class Subscribership < ActiveRecord::Base

  include Cancelable

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :subscription
  belongs_to :user

  scope :by_id, -> { order(id: :asc) }
  scope :by_user_id, -> { order(user_id: :asc) }
  scope :by_creation_date, -> { order(created_at: :asc) }

  scope :subscribed_user_ids, -> { not_canceled.by_user_id.distinct
                                    .pluck(:user_id) }

  after_create { record_activity :create, self }
  after_cancel :update_subscription

  validates :subscription_id, presence: true
  validate_id_for :subscription
  validates :user_id, presence: true
  validate_id_for :user


  # NOTE: The goal is that :to_s methods never do DB requests. If a :to_s with
  #       DB requests would be useful, implement a :to_s_detailed (see below).
  def to_s
    "Subscribership #{id.inspect}: user #{user_id}" +
      " - subscription: #{subscription_id}"
  end

  private

    def update_subscription
      # NOTE: Saving the subscription will update the denormalized_member_list
      #       and the updated_at date.
      subscription.touch_with_author(canceled_by)
    end
end
