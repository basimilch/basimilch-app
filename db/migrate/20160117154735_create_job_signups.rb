class CreateJobSignups < ActiveRecord::Migration[4.2]
  def change
    create_table :job_signups do |t|
      t.references :user, index: true, foreign_key: true
      t.references :job, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
