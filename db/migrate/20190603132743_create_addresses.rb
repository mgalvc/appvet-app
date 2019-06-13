class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.string :address
      t.string :cep

      t.belongs_to :client, index: true

      t.timestamps
    end
  end
end
