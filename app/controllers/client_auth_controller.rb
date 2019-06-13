class ClientAuthController < ApplicationController
    def login
        @user = Client.find_by_email(params[:email])

        if @user and @user.authenticate(params[:password])
            token = JsonWebToken.encode({ user_id: @user.id, is_admin: false })
            time = Time.now + 24.hours.to_i
            render json: { success: true, token: token, exp: time.strftime("%d/%m/%Y %H:%M"), name: @user.name, email:
                @user.email },
                   status:
                :ok
        else
            render json: {
                success: false,
                alerts: {
                    status: 'danger',
                    title: 'Erro'
                },
                message: 'Verifique os dados e tente novamente',
                error: 'Email ou senha incorretos'
            }, status: :ok
        end
    end

    private

    def login_params
        params.permit(:name, :email, :password)
    end
end
