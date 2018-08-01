class AddSeenCountToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :seen_count, :int, null: false, default: 0
  end
end
