class JobSignup < ActiveRecord::Base

  MIN_NUMBER_PER_USER_PER_YEAR = 4

  belongs_to :user
  belongs_to :job
end
