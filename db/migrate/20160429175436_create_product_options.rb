class CreateProductOptions < ActiveRecord::Migration

  # NOTE: About model vs database constrains:
  #       http://stackoverflow.com/questions/2367281/ruby-on-rails-is-it-better-to-validate-in-the-model-or-the-database
  #       https://github.com/vprokopchuk256/mv-core
  def change
    create_table :product_options do |t|
      t.string :name, null: false
      t.text :description
      t.string :picture
      t.decimal :size, null: false
      t.string :size_unit, null: false
      t.decimal :equivalent_in_milk_liters, null: false
      t.datetime :canceled_at
      t.string :canceled_reason
      t.references :canceled_by, references: :users, index: true
      t.text :notes

      t.timestamps null: false
    end
    add_foreign_key :product_options, :users, column: :canceled_by_id
  end
end
