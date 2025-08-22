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
      handle_user_login(user)
    elsif admin_user&.valid_password?(sign_in_params[:password])
      handle_admin_user_login(admin_user)
    else
      render_invalid_credentials
    end
  end

  def destroy
    if current_api_user
      sign_out(current_api_user)
    elsif current_admin_user
      sign_out(current_admin_user)
    end
    
    render json: { success: true, message: 'Signed out successfully' }
  end

  private

  def handle_user_login(user)
    sign_in(user)
    serializer = UserSerializer.new(user)
    serialized_data = serializer.as_json

    render json: { success: true, user: serialized_data }
  rescue StandardError => e
    render json: { success: false, message: 'Login failed' }, status: :internal_server_error
  end

  def handle_admin_user_login(admin_user)
    sign_in(admin_user)
    serializer = AdminUserSerializer.new(admin_user)
    serialized_data = serializer.as_json

    render json: { success: true, user: serialized_data }
  rescue StandardError => e
    render json: { success: false, message: 'Login failed' }, status: :internal_server_error
  end

  def render_invalid_credentials
    render json: { success: false, message: 'Invalid email or password' }, status: :unauthorized
  end

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

    response.headers['Access-Control-Allow-Origin'] = origin if origin && allowed_origins.include?(origin)

    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
  end
end
