class AddLoginTraceToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :last_login_at, :datetime
    add_column :users, :last_login_from, :string
  end
end
