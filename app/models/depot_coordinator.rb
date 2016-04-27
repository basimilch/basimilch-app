class DepotCoordinator < ActiveRecord::Base

  include Cancelable

  # DOC: https://github.com/airblade/paper_trail/tree/v4.1.0#basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :user
  belongs_to :depot

  default_scope -> { order(id: :asc) }

  def to_s
    "Depot coordinator #{id.inspect}: #{user}"
  end
end
