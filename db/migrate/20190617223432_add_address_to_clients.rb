class AddAddressToClients < ActiveRecord::Migration[5.2]
    def change
        add_column :clients, :address, :string
    end
end
