class Client < ApplicationRecord
    has_secure_password

    has_many :addresses, dependent: :delete_all

    validates :name, presence: true, length: { minimum: 3 }
    validates :email, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 6 }
end
