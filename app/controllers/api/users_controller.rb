class Api::UsersController < ApiController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut
  
  def current_user_info
    begin
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
    rescue => e
      render json: { success: false, user: nil }
    end
  end
end
