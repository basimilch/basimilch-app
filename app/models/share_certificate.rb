class ShareCertificate < ApplicationRecord

  # DOC: https://github.com/chaps-io/public_activity/tree/v1.4.1
  include PublicActivity::Common

  UNIT_PRICE = ENV['SHARE_CERTIFICATE_UNIT_PRICE'].to_i

  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#1c-basic-usage
  has_paper_trail ignore: [:updated_at]

  default_scope -> { order(id: :asc) }

  # NOTE: :after_initialize is triggered after each instantiation of the model,
  #       i.e. with a :new or with a :find call. To ensure that this only
  #       happens for new models, we add the condition 'if: :new_record?'
  # SOURCE: http://stackoverflow.com/a/33034815
  # DOC: http://api.rubyonrails.org/v5.1.3/classes/ActiveRecord/Callbacks.html
  after_initialize :init_values, if: :new_record?

  belongs_to :user
  validates  :user_id, presence: true
  validate_id_for :user
  validates  :value_in_chf, presence: true, numericality: {
    equal_to: UNIT_PRICE
  }

  def to_s
    "ShareCertificate #{id.inspect}: for user #{user_id.inspect}"
  end

  private

    def init_values
      self.value_in_chf ||= UNIT_PRICE
      self.created_at ||= Time.current
    end
end
