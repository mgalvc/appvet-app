class AddSentAtToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :sent_at, :timestamp
  end
end
