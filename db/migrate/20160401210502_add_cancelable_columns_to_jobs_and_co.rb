class AddCancelableColumnsToJobsAndCo < ActiveRecord::Migration[4.2]
  def change
    add_column      :jobs,        :canceled_at,     :datetime
    add_column      :jobs,        :canceled_reason, :string
    add_reference   :jobs,        :canceled_by, references: :users, index: true
    add_foreign_key :jobs,        :users, column: :canceled_by_id

    add_column      :job_signups, :canceled_at,     :datetime
    add_column      :job_signups, :canceled_reason, :string
    add_reference   :job_signups, :canceled_by, references: :users, index: true
    add_foreign_key :job_signups, :users, column: :canceled_by_id

    add_column      :job_types,   :canceled_at,     :datetime
    add_column      :job_types,   :canceled_reason, :string
    add_reference   :job_types,   :canceled_by, references: :users, index: true
    add_foreign_key :job_types,   :users, column: :canceled_by_id
  end
end
