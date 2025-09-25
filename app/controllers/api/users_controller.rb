class Api::UsersController < ApiController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut

  skip_before_action :verify_authenticity_token
  before_action :authenticate_any_user!, except: %i[current_user_info index]

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

  def index
    return render_unauthorized unless current_api_user || current_admin_user

    # Get regular users
    users = User.includes(:authored_poems, :source_texts)
                .order(:username)
                .limit(50) # Reduced to make room for admin users
                
    # Get admin users  
    admin_users = AdminUser.includes(:authored_poems, :source_texts)
                          .order(:email) # Admin users use email, not username
                          .limit(50)
                
    # Combine and format user data
    all_users_data = []
    
    # Add regular users
    users.each do |user|
      all_users_data << {
        id: user.id,
        username: user.username,
        full_name: user.full_name,
        gravatar_url: user.gravatar_url,
        source_texts_count: user.source_texts.count,
        poems_count: user.authored_poems.count,
        created_at: user.created_at,
        user_type: 'user'
      }
    end
    
    # Add admin users
    admin_users.each do |admin_user|
      all_users_data << {
        id: admin_user.id,
        username: admin_user.username || admin_user.email.split('@').first,
        full_name: admin_user.full_name,
        gravatar_url: admin_user.gravatar_url,
        source_texts_count: admin_user.source_texts.count,
        poems_count: admin_user.authored_poems.count,
        created_at: admin_user.created_at,
        user_type: 'admin'
      }
    end
    
    # Sort combined results by username/email
    all_users_data.sort_by! { |user| user[:username].downcase }

    render json: {
      success: true,
      users: all_users_data,
      total_count: all_users_data.length,
      regular_users_count: users.length,
      admin_users_count: admin_users.length
    }
  rescue StandardError => e
    render json: {
      success: false,
      message: "Failed to load users: #{e.message}"
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

  def render_unauthorized
    render json: {
      success: false,
      message: 'Authentication required to view users list'
    }, status: :unauthorized
  end

  def profile_params
    params.expect(user: %i[username first_name last_name bio gravatar_type])
  end

  def password_params
    params.expect(password_change: %i[current_password new_password])
  end
end
