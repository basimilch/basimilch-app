class CreateJobTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :job_types do |t|
      t.string :title
      t.text :description
      t.string :place
      t.string :address
      t.integer :slots
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
