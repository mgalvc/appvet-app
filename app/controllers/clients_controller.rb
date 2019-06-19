class ClientsController < ApplicationController
    before_action :authorize_request, except: :create
    before_action :find_client, only: [:update, :destroy, :get_waiting_items]

    # POST /clients
    def create
        @client = Client.new(client_params)
        if @client.save
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Cliente incluído com sucesso'
            }, status: :created
        else
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: save_errors
            }, status: :ok
        end
    end

    # PUT /clients/:id
    def update
        if @client.update(client_params)
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Cliente atualizado com sucesso'
            }, status: :created
        else
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: save_errors
            }, status: :ok
        end
    end

    def has_valid_token
        render json: {
            success: true
        }, status: :ok
    end

    # GET /clients/:id
    def show
        @client = Client.select(:id, :name, :email, :phone, :address).find(params[:id])
        render json: @client, status: :ok
    end

    # DELETE /clients/:id
    def destroy
        @client.destroy
        render json: { message: 'Client destroyed' }, status: :ok
    end

    # GET /clients/:id/waiting_items
    def get_waiting_items
        # each order has a list of items
        orders = @client.orders.where(status: 'waiting')
        items = []

        for order in orders
            for item in order.items
                product = Product.find(item.product_id)
                items.push({
                    id: item.id,
                    name: product.name,
                    price: item.price,
                    quantity: item.quantity,
                    picture: product.picture,
                    status: order.status
                           })
            end
        end

        render json: { items: items }, status: :ok
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'No orders found' }, status: :not_found
    end

    private

    def find_client
        @client = Client.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Client not found' }, status: :not_found
    end

    def client_params
        params.permit(:name, :email, :password, :password_confirmation, :address, :phone)
    end

    def save_errors
        errors = Hash.new

        if @client.errors.full_messages_for(:name).size > 0
            errors[:name] = @client.errors.full_messages_for(:name)
        end

        if @client.errors.full_messages_for(:email).size > 0
            errors[:email] = @client.errors.full_messages_for(:email)
        end

        if @client.errors.full_messages_for(:password).size > 0
            errors[:password] = @client.errors.full_messages_for(:password)
        end

        if @client.errors.full_messages_for(:password_confirmation).size > 0
            errors[:password_confirmation] = @client.errors.full_messages_for(:password_confirmation)
        end

        errors
    end
end
