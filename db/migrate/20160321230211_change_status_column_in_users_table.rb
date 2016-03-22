class ChangeStatusColumnInUsersTable < ActiveRecord::Migration
  def change
    # SOURCE: http://stackoverflow.com/a/2799787
    change_column :users, :status,  :string
  end
end
