class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :status
      t.string :price
      t.belongs_to :client, indexes: true

      t.timestamps
    end
  end
end
