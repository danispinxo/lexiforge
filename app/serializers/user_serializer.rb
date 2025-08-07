class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin

  def admin?
    false
  end
end
