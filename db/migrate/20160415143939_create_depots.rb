class CreateDepots < ActiveRecord::Migration
  def change
    create_table :depots do |t|
      t.string :name
      t.string :postal_address
      t.string :postal_address_supplement
      t.string :postal_code
      t.string :city
      t.string :country
      t.float :latitude
      t.float :longitude
      t.string :exact_map_coordinates
      t.string :picture
      t.text :directions
      t.integer :delivery_day
      t.integer :delivery_time
      t.string :opening_hours
      t.text :notes
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :depots, :users, column: :canceled_by_id
  end
end

