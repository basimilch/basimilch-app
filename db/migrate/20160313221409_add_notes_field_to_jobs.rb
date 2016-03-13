class AddNotesFieldToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :notes, :text
  end
end
