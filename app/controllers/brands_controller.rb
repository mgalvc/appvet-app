class BrandsController < ApplicationController
    before_action :authorize_request
    before_action :find_brand, only: [:show, :update, :destroy]

    # GET /brands
    def index
        direction = params[:direction] ? params[:direction] : 'desc'
        column = params[:column] ? params[:column] : 'description'
        description = ''

        @brands = Brand.order("#{column} #{direction.upcase}")

        if params[:description]
            description = params[:description]
            @brands = @brands.where("description LIKE '%#{description}%'")
        end

        total = @brands.count

        @brands = @brands.page(params[:page]).per(params[:per_page])

        response = {
            brands: @brands,
            params: {
                total: total,
                per_page: @brands.limit_value,
                current_page: @brands.current_page,
                last_page: @brands.total_pages,
                next_page: @brands.next_page,
                prev_page: @brands.prev_page,
                direction: direction,
                column: column
            },
            filters: {
                description: description
            }
        }
        render json: response, status: :ok
    end

    # POST /brands
    def create
        @brand = Brand.new(brand_params)
        if @brand.save
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Marca incluída com sucesso'
            }, status: :created
        else
            errors = {
                description: @brand.errors.full_messages_for(:description)
            }
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: errors
            }, status: :ok
        end
    end

    # GET /brands/:id
    def show

        render json: @brand, status: :ok
    end

    # PUT /brands/:id
    def update
        if @brand.update(brand_params)
            render json: {
                success: true,
                alerts: {
                    status: 'success',
                    title: 'Sucesso'
                },
                message: 'Marca atualizada com sucesso'
            }, status: :ok
        else
            errors = {
                description: @brand.errors.full_messages_for(:description)
            }
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os erros e tente novamente',
                errors: errors
            }, status: :ok
        end
    end

    # DELETE /brands/:id
    def destroy
        @brand.destroy
        render json: {
            success: true,
            alerts: {
                status: 'success',
                title: 'Sucesso'
            },
            message: 'Marcada deletada'
        }, status: :ok
    rescue ActiveRecord::DeleteRestrictionError => e
        render json: {
            success: false,
            alerts: {
                status: 'danger',
                title: 'Erro'
            },
            message: 'Marca não pode ser deletada pois existem produtos associados'
        }
    end

    # GET /brands/listing
    def listing
        @brands = Brand.select(:id, "description AS 'option'").order(:description)
        render json: {
            list: @brands
        }
    end

    private

    def find_brand
        @brand = Brand.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Brand not found' }, status: :not_found
    end

    def brand_params
        params.permit(:description)
    end
end
