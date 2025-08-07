class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin

  def admin
    object.admin?
  end
end
