class AdminAuthController < ApplicationController
    def login
        @user = Admin.find_by_username(params[:username])
        if @user.authenticate(params[:password])
            token = JsonWebToken.encode({ user_id: @user.id, is_admin: true })
            time = Time.now + 24.hours.to_i
            render json: { token: token, exp: time.strftime("%d/%m/%Y %H:%M"), username: @user.username }, status: :ok
        else
            render json: { error: 'unauthorized' }, status: :unauthorized
        end
    end

    private

    def login_params
        params.permit(:username, :password)
    end
end
