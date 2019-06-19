class Product < ApplicationRecord
    belongs_to :brand, optional: true
    has_many :items

    validates :name, presence: true, length: { minimum: 3 }
    validates :price, presence: true
    validates :quantity, presence: true
    validates :description, presence: true, length: { minimum: 5 }
    validates :category, presence: true
end
