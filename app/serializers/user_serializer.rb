class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, :created_at, :admin

  def admin
    object&.admin?
  end

  delegate :username, :first_name, :last_name, :bio, to: :object

  def full_name
    object&.full_name
  rescue StandardError => e
    Rails.logger.error "Error in UserSerializer#full_name: #{e.message}"
    nil
  end

  def gravatar_url
    object&.gravatar_url
  rescue StandardError => e
    Rails.logger.error "Error in UserSerializer#gravatar_url: #{e.message}"
    nil
  end
end
