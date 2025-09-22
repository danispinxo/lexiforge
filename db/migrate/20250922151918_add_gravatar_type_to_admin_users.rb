class AddGravatarTypeToAdminUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :admin_users, :gravatar_type, :string, default: 'retro', null: false
  end
end
