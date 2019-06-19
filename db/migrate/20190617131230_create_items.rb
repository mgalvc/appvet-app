class CreateItems < ActiveRecord::Migration[5.2]
    def change
        create_table :items do |t|
            t.integer :quantity
            t.belongs_to :order, indexes: true
            t.belongs_to :product, indexes: true
            t.timestamps
        end
    end
end
