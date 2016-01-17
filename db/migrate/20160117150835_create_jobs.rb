class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.date :date
      t.time :start_time
      t.time :end_time
      t.string :place
      t.string :address
      t.integer :size
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
