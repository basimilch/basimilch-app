class AddRequestColumnsToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :request_remote_ip, :string
    add_column :versions, :request_user_agent, :string
  end
end
