class AddLoginAuditToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_seen_at, :datetime
    add_column :users, :remembered_since, :datetime
  end
end
