class SubscriptionItem < ActiveRecord::Base

  include Cancelable

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  ALLOWED_QUANTITIES = (0..10) # Arbitrary upper limit

  default_scope { order(id: :asc) }

  scope :valid_since_on_or_after, ->(date) {
        not_canceled
          .where("valid_since >= ?", date.try(:to_date))
        }
  scope :valid_since_on_or_before, ->(date) {
        not_canceled
          .where("valid_since <= ?", date.try(:to_date))
        }
  scope :valid_until_on_or_after, ->(date) {
        not_canceled
          .where("valid_until >= ? OR valid_until IS NULL", date.try(:to_date))
        }
  scope :valid_within_period, ->(d1, d2) { valid_since_on_or_before(d1)
                                           .valid_until_on_or_after(d2) }
  scope :valid_on_date, ->(date) { valid_within_period(date, date) }
  scope :currently_valid, -> { valid_on_date(Date.today) }
  scope :open, -> { not_canceled.where(valid_until: nil) }

  def self.valid_since_dates
    not_canceled
      .remove_order
      .select(:valid_since)
      .distinct
      .order(valid_since: :asc)
      .pluck(:valid_since)
  end

  # Returns the quantity of the first matching product option.
  def self.quantity(product_option)
    where(product_option: product_option)
      .limit(1)
      .pluck(:quantity)
      .first
  end

  def self.product_options
    select(:product_option_id)
      .remove_order
      .distinct
      .includes(:product_option)
      .map(&:product_option)
  end

  def self.include_product_option?(product_option)
    where(product_option: product_option).limit(1).pluck(:id).count.to_b
  end

  def self.cancel_on_or_after_date(date, author: nil)
    raise "Date missing" if date.blank?
    valid_since_on_or_after(date).each { |item| item.cancel author: author }
  end

  belongs_to :subscription
  belongs_to :product_option

  after_create { record_activity :create, self }

  validates :subscription_id, presence: true
  validate_id_for :subscription
  validates :product_option_id, presence: true
  validate_id_for :product_option
  validates :quantity, presence: true,
              inclusion: { in: ALLOWED_QUANTITIES }
  validates :valid_since, presence: true,   timeliness: { type: :date }
  validates :valid_until, presence: false,  timeliness: { type: :date }

  # NOTE: The goal is that :to_s methods never do DB requests. If a :to_s with
  #       DB requests would be useful, implement a :to_s_detailed (see below).
  def to_s
    "SubscriptionItem #{id.inspect}:" +
      " subscription_id #{subscription_id}" +
      ", product_option_id #{product_option_id}" +
      ", quantity #{quantity}" +
      ", valid #{valid_since.inspect} - #{valid_until.inspect}" +
      (canceled? ? ', CANCELED' : '')
  end

  def closed?
    valid_until.present?
  end

  def close_at(last_validity_day)
    unless valid_since <= last_validity_day
      raise "Last validity day (#{last_validity_day}) must be before" +
            " :valid_since (#{valid_since})"
    end
    update_attribute(:valid_until, last_validity_day)
  end
end
