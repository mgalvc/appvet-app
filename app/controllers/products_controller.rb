class ProductsController < ApplicationController
    before_action :authorize_request
    before_action :find_product, only: [:show, :update, :destroy, :increment, :sold]

    # GET /products
    def index
        direction = params[:direction] ? params[:direction] : 'desc'
        column = params[:column] ? params[:column] : 'name'
        name = ''
        category = ''

        @products = Product.order("#{column} #{direction.upcase}")

        if params[:name]
            name = params[:name]
            @products = @products.where("name LIKE '%#{name}%'")
        end

        if params[:category]
            category = params[:category]
            @products = @products.where("category LIKE '%#{category}%'")
        end

        total = @products.count

        @products = @products.page(params[:page]).per(params[:per_page])

        response = {
            products: @products,
            params: {
                total: total,
                per_page: @products.limit_value,
                current_page: @products.current_page,
                last_page: @products.total_pages,
                next_page: @products.next_page,
                prev_page: @products.prev_page,
                direction: direction,
                column: column
            },
            filters: {
                name: name,
                category: category
            }
        }
        render json: response, status: :ok
    end

    # POST /products
    def create
        @product = Product.new(product_params)
        if @product.save
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Produto incluído com sucesso'
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

    # GET /products/:id
    def show
        render json: @product.to_json(include: [:brand]), status: :ok
    end

    # PUT /products/:id
    def update
        if @product.update(product_params)
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Produto atualizado com sucesso'
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

    # DELETE /products/:id
    def destroy
        @product.destroy
        render json: { message: 'Product destroyed' }, status: :ok
    end

    # PUT /products/:id/increment
    def increment
        quantity = @product.quantity
        if @product.update(quantity: quantity + params[:how_many])
            render json: @product, status: :ok
        else
            render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    # PUT /products/:id/sold
    def sold
        quantity = @product.quantity

        if params[:how_many] > quantity
            render json: { error: 'More to sell than available in stock' }, status: :unprocessable_entity
        elsif @product.update(quantity: quantity - params[:how_many])
            render json: @product, status: :ok
        else
            render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
        end
    end

    private

    def find_product
        @product = Product.includes(:brand).find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
    end

    def product_params
        params.permit(:name, :price, :quantity, :description, :category, :subcategory, :brand_id, :picture)
    end

    def save_errors
        errors = Hash.new

        if @product.errors.full_messages_for(:name).size > 0
            errors[:name] = @product.errors.full_messages_for(:name)
        end

        if @product.errors.full_messages_for(:price).size > 0
            errors[:price] = @product.errors.full_messages_for(:price)
        end

        if @product.errors.full_messages_for(:quantity).size > 0
            errors[:quantity] = @product.errors.full_messages_for(:quantity)
        end

        if @product.errors.full_messages_for(:description).size > 0
            errors[:description] = @product.errors.full_messages_for(:description)
        end

        if @product.errors.full_messages_for(:category).size > 0
            errors[:category] = @product.errors.full_messages_for(:category)
        end

        errors
    end
end
