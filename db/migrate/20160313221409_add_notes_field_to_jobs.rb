class AddNotesFieldToJobs < ActiveRecord::Migration[4.2]
  def change
    add_column :jobs, :notes, :text
  end
end
