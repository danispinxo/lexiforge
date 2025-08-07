class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  def admin?
    true
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at email id id_value remember_created_at reset_password_sent_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end
end
