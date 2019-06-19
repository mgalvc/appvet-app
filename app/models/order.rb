class Order < ApplicationRecord
    belongs_to :client
    has_many :items, dependent: :delete_all
end
