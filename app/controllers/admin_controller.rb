class AdminController < ApplicationController
    before_action :authorize_request

    def overview
        open_orders_count = Order.where(status: 'open').size
        sent_orders_count = Order.where(status: 'sent').size
        received_orders = Order.where(status: 'received')
        received_orders_count = received_orders.size
        products = Product.count
        sells = 0

        for order in received_orders
            sells += order.price.to_f
        end

        render json: {
            open_orders_count: open_orders_count,
            sent_orders_count: sent_orders_count,
            received_orders_count: received_orders_count,
            products: products,
            sells: sells
        }, status: :ok
    end
end
