class AdminAuthController < ApplicationController
    def login
        @user = Admin.find_by_username(params[:username])

        if @user and @user.authenticate(params[:password])
            token = JsonWebToken.encode({ user_id: @user.id, is_admin: true })
            time = Time.now + 24.hours.to_i
            render json: { token: token, exp: time.strftime("%d/%m/%Y %H:%M"), username: @user.username }, status: :ok
        else
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os dados e tente novamente',
                error: 'Usuário ou senha incorretos'
            }, status: :ok
        end
    end

    private

    def login_params
        params.permit(:username, :password)
    end
end
