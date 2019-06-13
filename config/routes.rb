Rails.application.routes.draw do
    post '/auth/admin/login', to: 'admin_auth#login'
    post '/auth/client/login', to: 'client_auth#login'

    get '/auth/check', to: 'clients#has_valid_token'

    get '/brands/listing', to: 'brands#listing'

    resources :brands, :products, :clients

    put '/products/:id/increment', to: 'products#increment'
    put '/products/:id/sold', to: 'products#sold'

end
