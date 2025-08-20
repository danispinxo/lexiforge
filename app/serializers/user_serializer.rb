class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :username, :first_name, :last_name, :bio, :full_name, :gravatar_url, :created_at, :admin

  def admin
    object.admin?
  end

  delegate :full_name, to: :object

  delegate :gravatar_url, to: :object
end
