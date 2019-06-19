class Client < ApplicationRecord
    has_secure_password

    has_many :orders

    validates :name, presence: true, length: { minimum: 3 }
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }, on: :create
end
