class Api::UsersController < ApiController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut

  skip_before_action :verify_authenticity_token
  before_action :authenticate_any_user!, except: [:current_user_info]

  def current_user_info
    if current_api_user
      render json: {
        success: true,
        user: UserSerializer.new(current_api_user).as_json
      }
    elsif current_admin_user
      render json: {
        success: true,
        user: AdminUserSerializer.new(current_admin_user).as_json
      }
    else
      render json: { success: false, user: nil }
    end
  rescue StandardError
    render json: { success: false, user: nil }
  end

  def update_profile
    user = current_api_user || current_admin_user

    if user.update(profile_params)
      serializer_class = user.is_a?(AdminUser) ? AdminUserSerializer : UserSerializer
      render json: {
        success: true,
        user: serializer_class.new(user).as_json,
        message: 'Profile updated successfully'
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
      message: "Profile update failed: #{e.message}",
      errors: [e.message]
    }, status: :internal_server_error
  end

  def change_password
    user = current_api_user || current_admin_user

    unless user.valid_password?(password_params[:current_password])
      render json: {
        success: false,
        message: 'Current password is incorrect',
        errors: ['Current password is incorrect']
      }, status: :unprocessable_content
      return
    end

    if user.update(password: password_params[:new_password])
      render json: {
        success: true,
        message: 'Password changed successfully'
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
      message: "Password change failed: #{e.message}",
      errors: [e.message]
    }, status: :internal_server_error
  end

  private

  def authenticate_any_user!
    return if current_api_user || current_admin_user

    render json: {
      success: false,
      message: 'Authentication required'
    }, status: :unauthorized
  end

  def profile_params
    params.require(:user).permit(:username, :first_name, :last_name, :bio)
  end

  def password_params
    params.require(:password_change).permit(:current_password, :new_password)
  end
end
