class AddJobTypeToJob < ActiveRecord::Migration
  def change
    add_reference :jobs, :job_type, index: true, foreign_key: true
  end
end
