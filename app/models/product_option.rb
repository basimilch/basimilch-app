class ProductOption < ActiveRecord::Base

  include Cancelable

  # TODO: before_cancel :verify_not_used

  has_many :subscription_items
  has_many :subscriptions, through: :subscription_items

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  default_scope -> { by_id }
  scope :by_id, -> { order(id: :asc) }
  scope :by_name, -> { order(name: :asc).by_id }

  MIN_SIZE = 0.1

  class SizeUnit < Enum
    enum :MILLILITER
    enum :CENTILITER
    enum :DECILITER
    enum :LITER
    enum :GRAM
    enum :KILOGRAM
  end

  validates :name,          presence: true,  length: { maximum: 100 }
  validates :description,   presence: false, length: { maximum: 500 }
  validates :notes,         presence: false, length: { maximum: 1000 }
  validates :size,          presence: true, numericality: {
                                              greater_than_or_equal_to: MIN_SIZE
                                            }
  validates :size_unit,     presence: true,  inclusion: { in: SizeUnit.all }
  validates :equivalent_in_milk_liters, presence: true, numericality: {
                                              greater_than_or_equal_to: MIN_SIZE
                                            }

  def to_s
    "ProductOption #{id.inspect}: #{name.inspect} - #{size} #{size_unit}"
  end
end
