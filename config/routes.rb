Rails.application.routes.draw do
    get 'order/create'
    post '/auth/admin/login', to: 'admin_auth#login'
    post '/auth/client/login', to: 'client_auth#login'

    get '/auth/check', to: 'clients#has_valid_token'

    get '/brands/listing', to: 'brands#listing'

    resources :brands, :products, :clients, :orders

    get '/orders_grouped', to: 'orders#index_grouped'
    get '/order_items/:id', to: 'orders#items'

    get '/clients/:id/waiting_items', to: 'clients#get_waiting_items'

    put '/send_order/:id', to: 'orders#send_order'

    put '/products/:id/increment', to: 'products#increment'
    put '/products/:id/sold', to: 'products#sold'

end
