class AdminUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin

  def admin?
    true
  end
end
