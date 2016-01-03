class RemovePasswordRelatedColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :password_digest, :string
    remove_column :users, :password_reset_digest, :string
    remove_column :users, :password_reset_at, :datetime
    remove_column :users, :password_reset_sent_at, :datetime
  end
end
