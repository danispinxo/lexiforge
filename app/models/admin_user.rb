class AdminUser < ApplicationRecord
  require 'digest'

  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :authored_poems, class_name: 'Poem', as: :author, dependent: :nullify

  validates :username, uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/ },
                       allow_blank: true
  validates :first_name, length: { maximum: 50 }, allow_blank: true
  validates :last_name, length: { maximum: 50 }, allow_blank: true
  validates :bio, length: { maximum: 500 }

  before_validation :downcase_username

  def admin?
    true
  end

  def full_name
    return email if first_name.blank? && last_name.blank?

    "#{first_name} #{last_name}".strip
  end

  def gravatar_url(size = 80)
    return nil if email.blank?

    email_hash = Digest::MD5.hexdigest(email.downcase.strip)
    "https://www.gravatar.com/avatar/#{email_hash}?s=#{size}&d=retro"
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[
      created_at email id id_value remember_created_at reset_password_sent_at updated_at
      username first_name last_name bio
    ]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  private

  def downcase_username
    self.username = username&.downcase
  end
end
