class AddAuthorToJobSignups < ActiveRecord::Migration[4.2]
  def change
    # SOURCE: http://stackoverflow.com/a/29577869
    add_reference :job_signups, :author, references: :users, index: true
    add_foreign_key :job_signups, :users, column: :author_id
  end
end
