class AddPriceToShareCertificates < ActiveRecord::Migration[4.2]
  def change
    add_column :share_certificates, :value_in_chf, :int
  end
end
