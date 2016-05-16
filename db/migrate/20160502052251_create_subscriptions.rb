class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.string :name, limit: 100
      t.integer :basic_units, null: false, default: 1
      t.integer :supplement_units, null: false, default: 0
      t.references :depot, index: true, foreign_key: true
      t.string :denormalized_items_list
      t.string :denormalized_subscribers_list
      t.text :notes, limit: 1000
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :subscriptions, :users, column: :canceled_by_id
  end
end
