class ApplicationController < ActionController::API
    def authorize_request
        header = request.headers['Authorization']
        header = header.split(' ').last if header
        begin
            @decoded = JsonWebToken.decode(header)
            if @decoded[:is_admin]
                @current_user = Admin.find_by(id: @decoded[:user_id])
            else
                @current_user = Client.find_by(id: @decoded[:user_id])
            end
        rescue ActiveRecord::RecordNotFound => e
            render json: { error: e.message }, status: :unauthorized
        rescue JWT::DecodeError => e
            render json: { error: e.message }, status: :unauthorized
        end
    end
end
