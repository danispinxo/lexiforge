class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, :created_at, :admin

  def admin
    object.admin?
  end

  delegate :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, to: :object, allow_nil: true
end
