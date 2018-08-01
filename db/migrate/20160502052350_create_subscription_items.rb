class CreateSubscriptionItems < ActiveRecord::Migration[4.2]
  def change
    create_table :subscription_items do |t|
      t.references :subscription, index: true, foreign_key: true
      t.references :product_option, index: true, foreign_key: true
      t.integer :quantity, null: false, default: 0
      t.date :valid_since, null: false
      t.date :valid_until
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :subscription_items, :users, column: :canceled_by_id
  end
end
