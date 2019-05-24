class Brand < ApplicationRecord
    has_many :products, dependent: :restrict_with_exception
    validates :description, presence: true, uniqueness: true, length: { minimum: 3 }
end
