class Api::RegistrationsController < ApiController
  include Devise::Controllers::SignInOut
  include Devise::Controllers::Helpers

  before_action :configure_sign_up_params, only: [:create]

  def create
    existing_user = User.find_by(email: sign_up_params[:email])
    if existing_user
      render json: {
        success: false,
        message: 'Email has already been taken',
        errors: ['Email has already been taken']
      }, status: :unprocessable_content
      return
    end

    user = User.new(sign_up_params)

    if user.save
      sign_in(user)
      render json: {
        success: true,
        user: {
          id: user.id,
          email: user.email,
          created_at: user.created_at
        }
      }
    else
      render json: {
        success: false,
        message: user.errors.full_messages.join(', '),
        errors: user.errors.full_messages
      }, status: :unprocessable_content
    end
  rescue StandardError => e
    render json: {
      success: false,
      message: "Registration failed: #{e.message}",
      errors: [e.message]
    }, status: :internal_server_error
  end

  private

  def resource_class
    User
  end

  def resource_name
    :user
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[email password password_confirmation username first_name last_name bio])
  end

  def sign_up_params
    if params[:registration]
      params.require(:registration).permit(:email, :password, :password_confirmation, :username, :first_name,
                                           :last_name, :bio)
    else
      params.permit(:email, :password, :password_confirmation, :username, :first_name, :last_name, :bio)
    end
  end
end
