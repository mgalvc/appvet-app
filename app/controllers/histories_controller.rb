class HistoriesController < ApplicationController
    before_action :authorize_request
    before_action :find_history, only: [:show]

    def bill
        @histories = History.where("MONTH(delivery_date) = #{params[:month]}")

        total = 0

        for log in @histories
            total += log.price.to_f
        end

        response = {
            total: total,
            bill: total * 0.02
        }

        render json: response, status: :ok
    end

    # GET /histories
    def index
        direction = params[:direction] ? params[:direction] : 'desc'
        column = params[:column] ? params[:column] : 'delivery_date'
        year = ''
        month = ''

        @histories = History.order("#{column} #{direction.upcase}")

        if params[:year]
            year = params[:year]
            @histories = @histories.where("YEAR(delivery_date) = #{params[:year]}")
        end

        if params[:month]
            month = params[:month]
            @histories = @histories.where("MONTH(delivery_date) = #{params[:month]}")
        end

        total = @histories.count

        @histories = @histories.page(params[:page]).per(params[:per_page])

        response = {
            histories: @histories,
            params: {
                total: total,
                per_page: @histories.limit_value,
                current_page: @histories.current_page,
                last_page: @histories.total_pages,
                next_page: @histories.next_page,
                prev_page: @histories.prev_page,
                direction: direction,
                column: column
            },
            filters: {
                year: year,
                month: month
            }
        }
        render json: response, status: :ok
    end

    # GET /histories/:id
    def show
        render json: @history, status: :ok
    end

    private

    def find_history
        @history = History.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        render json: { error: 'Log not found' }, status: :not_found
    end
end
