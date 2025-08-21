ActiveAdmin.register AdminUser do
  permit_params :email, :username, :first_name, :last_name, :bio, :password, :password_confirmation

  index do
    selectable_column
    id_column
    column :email
    column :username
    column :full_name
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :email
      row :username
      row :first_name
      row :last_name
      row :bio do |admin_user|
        if admin_user.respond_to?(:bio) && admin_user.bio.present?
          simple_format(admin_user.bio)
        else
          'No bio'
        end
      end
      row :full_name
      row :created_at
      row :updated_at
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :remember_created_at
    end

    panel "Authored Poems (#{admin_user.authored_poems.count})" do
      if admin_user.authored_poems.any?
        table_for admin_user.authored_poems.includes(:source_text).order(created_at: :desc) do
          column :title do |poem|
            link_to poem.title, admin_poem_path(poem)
          end
          column :technique_used
          column :source_text do |poem|
            link_to poem.source_text.title, admin_source_text_path(poem.source_text) if poem.source_text
          end
          column 'Content Preview' do |poem|
            truncate(poem.content, length: 100) if poem.content
          end
          column :created_at do |poem|
            poem.created_at.strftime('%m/%d/%Y')
          end
        end
      else
        div class: 'blank_slate_container' do
          span class: 'blank_slate' do
            span 'No poems authored yet'
          end
        end
      end
    end
  end

  filter :email
  filter :username
  filter :first_name
  filter :last_name
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs 'Admin User Details' do
      f.input :email
      f.input :username, required: false,
                         hint: 'Optional - Must be 3-30 characters, letters, numbers and underscores only'
      f.input :first_name, required: false, hint: 'Optional'
      f.input :last_name, required: false, hint: 'Optional'
      f.input :bio, as: :text, required: false, input_html: { rows: 4 }, hint: 'Optional - Maximum 500 characters'
    end

    f.inputs 'Password' do
      f.input :password, hint: 'Leave blank to keep current password'
      f.input :password_confirmation, hint: 'Required only if changing password'
    end

    f.actions
  end

  controller do
    def update
      if params[:admin_user][:password].blank?
        params[:admin_user].delete(:password)
        params[:admin_user].delete(:password_confirmation)
      end
      super
    end

    def create
      if params[:admin_user][:password].blank?
        params[:admin_user].delete(:password)
        params[:admin_user].delete(:password_confirmation)
      end
      super
    end
  end
end
