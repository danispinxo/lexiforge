class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :created_at, :admin

  # rubocop:disable Naming/PredicateMethod
  def admin
    object.admin?
  end
  # rubocop:enable Naming/PredicateMethod
end
