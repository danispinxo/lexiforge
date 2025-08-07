class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  def admin?
    false
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at current_sign_in_at current_sign_in_ip email encrypted_password id id_value
       last_sign_in_at last_sign_in_ip remember_created_at reset_password_sent_at reset_password_token sign_in_count updated_at]
  end
end
