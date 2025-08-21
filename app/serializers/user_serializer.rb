class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, :created_at, :admin

  def admin
    object&.admin?
  end

  def username
    object.respond_to?(:username) ? object.username : nil
  end

  def first_name
    object.respond_to?(:first_name) ? object.first_name : nil
  end

  def last_name
    object.respond_to?(:last_name) ? object.last_name : nil
  end

  def bio
    object.respond_to?(:bio) ? object.bio : nil
  end

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
