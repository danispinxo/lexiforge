class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, :created_at, :admin

  def admin
    object.admin?
  end

  def full_name
    object.full_name
  end

  def gravatar_url
    object.gravatar_url
  end
end
