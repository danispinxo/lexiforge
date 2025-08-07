class Api::UsersController < ApiController
  include Devise::Controllers::Helpers
  include Devise::Controllers::SignInOut
  
  def current_user_info
    begin
      if current_api_user
        render json: {
          success: true,
          user: {
            id: current_api_user.id,
            email: current_api_user.email,
            created_at: current_api_user.created_at
          }
        }
      else
        render json: { success: false, user: nil }
      end
    rescue => e
      render json: { success: false, user: nil }
    end
  end
end
