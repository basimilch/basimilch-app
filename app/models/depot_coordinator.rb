class DepotCoordinator < ApplicationRecord

  include Cancelable

  # DOC: https://github.com/airblade/paper_trail/tree/v5.1.1#1c-basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :user
  belongs_to :depot

  before_save :check_if_tel_mobile_present

  default_scope -> { order(id: :asc) }

  def to_s
    "Depot coordinator #{id.inspect}: #{user}"
  end

  private
    def check_if_tel_mobile_present
      self.publish_tel_mobile = publish_tel_mobile && user.tel_mobile.present?
      return true # don't stop the save action
    end
end
