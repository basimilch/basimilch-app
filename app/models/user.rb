class User < ActiveRecord::Base

  # Inspired from
  #   https://www.railstutorial.org/book/_single-page#sec-format_validation
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,       presence: true,
                          length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          uniqueness: { case_sensitive: false }
  before_save { self.email = email.downcase }

  validates :password,    presence: true,
                          length: { in: 8..100 }

  validates :first_name,  presence: true,
                          length: { maximum: 40 }

  validates :last_name,   presence: true,
                          length: { maximum: 40 }

  after_initialize { self.country = I18n.t :switzerland }
  has_secure_password
end
