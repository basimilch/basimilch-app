class AddRequestColumnsToVersions < ActiveRecord::Migration[4.2]
  def change
    add_column :versions, :request_remote_ip, :string
    add_column :versions, :request_user_agent, :string
  end
end
