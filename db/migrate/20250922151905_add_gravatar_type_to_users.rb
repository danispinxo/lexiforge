class AddGravatarTypeToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :gravatar_type, :string, default: 'retro', null: false
  end
end
