class AdminUser < ApplicationRecord
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "email", "id", "id_value", "remember_created_at", "reset_password_sent_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
