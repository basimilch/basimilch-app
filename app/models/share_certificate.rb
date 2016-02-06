class ShareCertificate < ActiveRecord::Base

  # DOC: https://github.com/airblade/paper_trail/tree/v4.0.1#basic-usage
  has_paper_trail ignore: [:updated_at]

  belongs_to :user
  validates  :user_id, presence: true
  validate   :user_exists

  private

    def user_exists
      unless User.find_by(id: user_id)
        errors.add(:user_id, I18n.t("errors.messages.user_not_found",
                                    id: user_id))
      end
    end
end
