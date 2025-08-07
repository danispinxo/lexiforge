class Api::SessionsController < Devise::SessionsController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut
  
  skip_before_action :verify_authenticity_token
  skip_before_action :require_no_authentication, only: [:create]
  after_action :set_cors_headers
  
  def create      
    user = User.find_by(email: sign_in_params[:email])
    admin_user = AdminUser.find_by(email: sign_in_params[:email])
    
    if user&.valid_password?(sign_in_params[:password])
      begin
        sign_in(user)
        render json: {
          success: true,
          user: UserSerializer.new(user).as_json
        }
      rescue => e
        render json: {
          success: false,
          message: 'Login failed'
        }, status: :internal_server_error
      end
    elsif admin_user&.valid_password?(sign_in_params[:password])
      begin
        sign_in(admin_user)
        render json: {
          success: true,
          user: AdminUserSerializer.new(admin_user).as_json
        }
      rescue => e
        render json: {
          success: false,
          message: 'Login failed'
        }, status: :internal_server_error
      end
    else
      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def destroy
    sign_out(current_api_user) if current_api_user
    render json: { success: true, message: 'Signed out successfully' }
  end

  private

  def sign_in_params
    if params[:session]
      params.require(:session).permit(:email, :password)
    else
      params.permit(:email, :password)
    end
  end

  def set_cors_headers
    allowed_origins = ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3001').split(',')
    origin = request.headers['Origin']
    
    if origin && allowed_origins.include?(origin)
      response.headers['Access-Control-Allow-Origin'] = origin
    end
    
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
  end
end
