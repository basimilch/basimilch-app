class AddPriceToShareCertificates < ActiveRecord::Migration
  def change
    add_column :share_certificates, :value_in_chf, :int
  end
end
