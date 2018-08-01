class CreateShareCertificates < ActiveRecord::Migration[4.2]
  def change
    create_table :share_certificates do |t|
      t.references :user, index: true, foreign_key: true
      t.date :sent_at
      t.date :payed_at
      t.date :returned_at
      t.text :notes

      t.timestamps null: false
    end
  end
end
