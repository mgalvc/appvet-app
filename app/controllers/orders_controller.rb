class OrdersController < ApplicationController
    before_action :authorize_request
    before_action :find_order, only: [:destroy, :send_order, :receive_order, :items]

    def receive_order
        @order.update(status: 'received')

        render json: {
            success: true,
            alerts: {
                status: 'success',
                title: 'Sucesso'
            },
            message: 'Ordem recebida com sucesso'
        }, status: :created
    end

    def send_order
        # run through items just to check if there are enough products to deliver
        errors = []

        for item in @order.items
            if item.quantity > item.product.quantity
                errors.push("Você não tem estoque suficiente de #{item.product.name} para esta entrega.")
            end
        end

        if errors.size > 0
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: errors
            }, status: :ok
            return
        end

        for item in @order.items
            item.product.decrement(:quantity, item.quantity).save
        end

        @order.update(status: 'sent', sent_at: Time.now)

        render json: {
            success: true,
            alerts: {
                status: 'success',
                title: 'Sucesso'
            },
            message: 'Ordem enviada com sucesso'
        }, status: :created
    end

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
        if params[:status]
            @orders = Order.where(status: params[:status])
        else
            @orders = Order.all
        end

        if params[:last]
            @orders = @orders.order(updated_at: :desc).limit(params[:last])
        end

        @orders = @orders.group_by(&:status)

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
        @items = @order.items.includes(:product)
        render json: @items, include: [:product], status: :ok
    end

    # DELETE /orders/:id
    def destroy
        @order.items.delete_all
        @order.destroy
        render json: { message: 'Order destroyed' }, status: :ok
    end

    private

    def find_order
        @order = Order.find(params[:id])
    end

    def order_params
        params.permit(:status, :price, :client_id, :delivery_address, items: [])
    end
end
