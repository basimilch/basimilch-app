class AddJobTypeToJob < ActiveRecord::Migration[4.2]
  def change
    add_reference :jobs, :job_type, index: true, foreign_key: true
  end
end
