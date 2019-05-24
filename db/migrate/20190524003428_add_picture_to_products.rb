class AddPictureToProducts < ActiveRecord::Migration[5.2]
    def change
        add_column :products, :picture, :binary, limit: 10.megabyte
    end
end
