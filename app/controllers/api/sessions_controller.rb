class Api::SessionsController < Devise::SessionsController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut

  skip_before_action :verify_authenticity_token
  skip_before_action :require_no_authentication, only: [:create]
  after_action :set_cors_headers

  def create
    Rails.logger.info "=== LOGIN ATTEMPT START ==="
    Rails.logger.info "Email: #{sign_in_params[:email]}"
    
    user = User.find_by(email: sign_in_params[:email])
    admin_user = AdminUser.find_by(email: sign_in_params[:email])
    
    Rails.logger.info "User found: #{user.present?}"
    Rails.logger.info "Admin user found: #{admin_user.present?}"

    if user&.valid_password?(sign_in_params[:password])
      Rails.logger.info "=== USER LOGIN PATH ==="
      Rails.logger.info "User ID: #{user.id}, Email: #{user.email}"
      Rails.logger.info "User attributes: #{user.attributes.except('encrypted_password')}"
      
      begin
        Rails.logger.info "Signing in user..."
        sign_in(user)
        Rails.logger.info "User signed in successfully"
        
        Rails.logger.info "Creating UserSerializer..."
        serializer = UserSerializer.new(user)
        Rails.logger.info "UserSerializer created successfully"
        
        Rails.logger.info "Converting to JSON..."
        serialized_data = serializer.as_json
        Rails.logger.info "Serialization successful"
        
        render json: {
          success: true,
          user: serialized_data
        }
        Rails.logger.info "Response rendered successfully"
      rescue StandardError => e
        Rails.logger.error "=== USER LOGIN ERROR ==="
        Rails.logger.error "Error class: #{e.class}"
        Rails.logger.error "Error message: #{e.message}"
        Rails.logger.error "User object state: #{user.inspect}"
        Rails.logger.error "Backtrace:"
        Rails.logger.error e.backtrace.join("\n")
        render json: {
          success: false,
          message: 'Login failed'
        }, status: :internal_server_error
      end
    elsif admin_user&.valid_password?(sign_in_params[:password])
      Rails.logger.info "=== ADMIN USER LOGIN PATH ==="
      Rails.logger.info "Admin User ID: #{admin_user.id}, Email: #{admin_user.email}"
      Rails.logger.info "Admin User attributes: #{admin_user.attributes.except('encrypted_password')}"
      
      begin
        Rails.logger.info "Signing in admin user..."
        sign_in(admin_user)
        Rails.logger.info "Admin user signed in successfully"
        
        Rails.logger.info "Creating AdminUserSerializer..."
        serializer = AdminUserSerializer.new(admin_user)
        Rails.logger.info "AdminUserSerializer created successfully"
        
        Rails.logger.info "Converting to JSON..."
        serialized_data = serializer.as_json
        Rails.logger.info "Serialization successful"
        
        render json: {
          success: true,
          user: serialized_data
        }
        Rails.logger.info "Response rendered successfully"
      rescue StandardError => e
        Rails.logger.error "=== ADMIN USER LOGIN ERROR ==="
        Rails.logger.error "Error class: #{e.class}"
        Rails.logger.error "Error message: #{e.message}"
        Rails.logger.error "Admin user object state: #{admin_user.inspect}"
        Rails.logger.error "Backtrace:"
        Rails.logger.error e.backtrace.join("\n")
        render json: {
          success: false,
          message: 'Login failed'
        }, status: :internal_server_error
      end
    else
      Rails.logger.info "=== LOGIN FAILED - INVALID CREDENTIALS ==="
      render json: {
        success: false,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
    
    Rails.logger.info "=== LOGIN ATTEMPT END ==="
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

    response.headers['Access-Control-Allow-Origin'] = origin if origin && allowed_origins.include?(origin)

    response.headers['Access-Control-Allow-Credentials'] = 'true'
    response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, PATCH, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, X-Requested-With'
  end
end
