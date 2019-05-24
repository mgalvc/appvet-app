class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :price
      t.integer :quantity
      t.text :description
      t.string :category
      t.string :subcategory

      t.belongs_to :brand, index: true

      t.timestamps
    end
  end
end
