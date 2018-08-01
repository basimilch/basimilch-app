class AddPostalAddressSupplementToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :postal_address_supplement, :string
  end
end
