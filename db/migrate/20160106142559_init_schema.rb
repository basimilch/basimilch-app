class InitSchema < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string   :email
      t.boolean  :admin,              default: false, null: false
      t.string   :first_name
      t.string   :last_name
      t.string   :postal_address
      t.string   :postal_code
      t.string   :city
      t.string   :country
      t.string   :tel_mobile
      t.string   :tel_home
      t.string   :tel_office
      t.integer  :status
      t.text     :notes
      t.datetime :created_at,                         null: false
      t.datetime :updated_at,                         null: false
      t.string   :remember_digest
      t.datetime :last_seen_at
      t.datetime :remembered_since
      t.boolean  :activated,          default: false
      t.datetime :activated_at
      t.datetime :activation_sent_at
      t.float    :latitude
      t.float    :longitude
      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
