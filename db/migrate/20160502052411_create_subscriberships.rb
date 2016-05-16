class CreateSubscriberships < ActiveRecord::Migration
  def change
    create_table :subscriberships do |t|
      t.references :subscription, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :subscriberships, :users, column: :canceled_by_id
  end
end
