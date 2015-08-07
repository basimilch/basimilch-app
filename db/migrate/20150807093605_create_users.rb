class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.boolean :admin, null: false, default: false
      t.string :first_name
      t.string :last_name
      t.string :postal_address
      t.string :postal_code
      t.string :city
      t.string :country
      t.string :tel_mobile
      t.string :tel_home
      t.string :tel_office
      t.integer :status
      t.text :notes

      t.timestamps null: false
    end
    add_index :users, :email, unique: true
  end
end
