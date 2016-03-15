class AddSeenCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :seen_count, :int, null: false, default: 0
  end
end
