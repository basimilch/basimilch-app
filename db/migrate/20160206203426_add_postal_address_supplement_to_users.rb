class AddPostalAddressSupplementToUsers < ActiveRecord::Migration
  def change
    add_column :users, :postal_address_supplement, :string
  end
end
