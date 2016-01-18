class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.string :title
      t.text :description
      t.datetime :start_at
      t.datetime :end_at
      t.string :place
      t.string :address
      t.integer :slots
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
