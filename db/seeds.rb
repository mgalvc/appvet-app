require 'faker'

#Admin.create!(username: 'root', password: 'root_admin')

# 40.times do
#     Brand.create(description: Faker::Company.name)
# end

10.times do
    Product.create(name: Faker::Commerce.material, price: Faker::Commerce.price, quantity: Faker::Number.number(2),
                    description: Faker::Commerce.product_name, category: Faker::Commerce.material, subcategory:
                        Faker::Commerce.material, brand_id: Faker::Number.between(1, 3))
end




