Rails.application.routes.draw do
    post '/auth/admin/login', to: 'admin_auth#login'

    get '/brands/listing', to: 'brands#listing'

    resources :brands, :products

    put '/products/:id/increment', to: 'products#increment'
    put '/products/:id/sold', to: 'products#sold'

end
