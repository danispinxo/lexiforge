class Api::UsersController < ApiController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut

  before_action :authenticate_api_user!, except: [:current_user_info]

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
    if current_api_user.update(profile_params)
      render json: {
        success: true,
        user: UserSerializer.new(current_api_user).as_json,
        message: 'Profile updated successfully'
      }
    else
      render json: {
        success: false,
        message: current_api_user.errors.full_messages.join(', '),
        errors: current_api_user.errors.full_messages
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
    unless current_api_user.valid_password?(password_params[:current_password])
      render json: {
        success: false,
        message: 'Current password is incorrect',
        errors: ['Current password is incorrect']
      }, status: :unprocessable_content
      return
    end

    if current_api_user.update(password: password_params[:new_password])
      render json: {
        success: true,
        message: 'Password changed successfully'
      }
    else
      render json: {
        success: false,
        message: current_api_user.errors.full_messages.join(', '),
        errors: current_api_user.errors.full_messages
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

  def profile_params
    params.require(:user).permit(:username, :first_name, :last_name, :bio)
  end

  def password_params
    params.require(:password_change).permit(:current_password, :new_password)
  end
end
