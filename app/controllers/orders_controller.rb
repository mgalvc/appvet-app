class OrdersController < ApplicationController
    before_action :authorize_request

    # POST /orders
    def create
        @order = Order.new(order_params)

        for item in params[:items]
            @order.items.build(quantity: item[:quantity], product_id: item[:id], price: item[:price])
        end

        if @order.save
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Ordem incluída com sucesso'
            }, status: :created
        else
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: @order.errors.full_messages
            }, status: :ok
        end
    end

    def index_grouped
        @orders = Order.all.group_by(&:status)
        render json: { orders: @orders }, include: [:items], status: :ok
    end

    # GET /orders
    def index
        direction = params[:direction] ? params[:direction] : 'desc'
        column = params[:column] ? params[:column] : 'created_at'
        status = params[:status] ? params[:status] : 'waiting'
        client_id = ''

        @orders = Order.order("#{column} #{direction.upcase}").where(status: status)

        if params[:client_id]
            client_id = params[:client_id]
            @orders = @orders.where(client_id: client_id)
        end

        total = @orders.count

        @orders = @orders.page(params[:page]).per(params[:per_page])

        response = {
            orders: @orders,
            params: {
                total: total,
                per_page: @orders.limit_value,
                current_page: @orders.current_page,
                last_page: @orders.total_pages,
                next_page: @orders.next_page,
                prev_page: @orders.prev_page,
                direction: direction,
                column: column,
            },
            filters: {
                client_id: client_id,
                status: status
            }
        }
        render json: response, include: [:items], status: :ok
    end

    # GET /order_items/:id
    def items
        @items = Order.find(params[:id]).items.includes(:product)
        render json: @items, include: [:product], status: :ok
    end

    # DELETE /orders/:id
    def destroy
        @order = Order.find(params[:id])
        @order.items.delete_all
        @order.destroy
        render json: { message: 'Order destroyed' }, status: :ok
    end

    private

    def order_params
        params.permit(:status, :price, :client_id, :delivery_address, items: [])
    end
end
