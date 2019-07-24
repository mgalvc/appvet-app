class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.string :client
      t.timestamp :order_date
      t.timestamp :delivery_date
      t.string :delivery_address
      t.text :products
      t.string :price

      t.timestamps
    end
  end
end
