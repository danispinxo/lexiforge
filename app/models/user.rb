class User < ApplicationRecord
  require 'digest'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  validates :username, presence: true, uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/ }
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :bio, length: { maximum: 500 }

  before_validation :downcase_username

  def admin?
    false
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def gravatar_url(size = 80)
    email_hash = Digest::MD5.hexdigest(email.downcase.strip)
    "https://www.gravatar.com/avatar/#{email_hash}?s=#{size}&d=retro"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at current_sign_in_at current_sign_in_ip email encrypted_password id id_value
      last_sign_in_at last_sign_in_ip remember_created_at reset_password_sent_at
      reset_password_token sign_in_count updated_at username first_name last_name bio
    ]
  end

  private

  def downcase_username
    self.username = username&.downcase
  end
end
