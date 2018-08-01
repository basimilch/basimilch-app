class CreateDepotCoordinators < ActiveRecord::Migration[4.2]
  def change
    create_table :depot_coordinators do |t|
      t.references :user, index: true, foreign_key: true
      t.references :depot, index: true, foreign_key: true
      t.boolean :publish_email, default: true
      t.boolean :publish_tel_mobile, default: true
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true

      t.timestamps null: false
    end
    add_foreign_key :depot_coordinators, :users, column: :canceled_by_id
  end
end
